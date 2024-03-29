#
# Crawler Class
# Class that manages crawling the websites/ inserting values in database
#

pwd = File.dirname(File.expand_path(__FILE__))

require 'rubygems'
require 'mechanize'
require 'logger'
require 'rss'
require 'uri'
require "net/http"
require pwd + '/db_connection.rb'
require pwd + '/db.rb'

class Crawler
  @@url_regex = /^ ((http|https|ftp):\/\/(\S*?\.\S*?))(\s|\;|\)|\]|\[|\{|\}|,|\"|'|:|\<|$|\.\s) $/ix
  @@url_regex3 = /^(http|https):\/\/   (([a-z0-9]+[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5})(:[0-9]{1,5})?(\/.*)?$/ix
  @@url_regex2 = /^
    (    (https?):\/\/                            )? # 2: protocol
    (    [a-z\d]+[\-\.]([a-z\d]+)*\.[a-z]{2,6}    )  # 3: domain
    (
      (:
        (      \d{1,5}                           )  # 7: port
      )?
      (        \/.*                                 )? # 8: query
    )?
    $/ix

  @@inter_item_delay = 10
  @@cycle_delay = 10 * 60

  @@pwd = File.dirname(File.expand_path(__FILE__))
  @@logger = Logger.new(@@pwd + "/../log/crawler.log")
  @@agent = nil
  def self.run
    agent = Mechanize.new { |a| a.log = @@logger }
    @@agent = agent
    while true
      sources = ContentSource.find :all
      sources.each do |source|
        @@logger.log Logger::WARN, "Fetching Content from source " + source.url
        if source.mobile
          agent.user_agent = 'Mozilla/5.0 (Linux; U; Android 2.2; en-us) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
        else
          agent.user_agent_alias = "Linux Firefox"
        end
        begin
          if (source.source_type == 0) # Web
            parse_web_page(agent, source)
          elsif (source.source_type == 1) # RSS
            parse_rss(agent, source)
          elsif source.source_type == 2 # Web Article
            parse_web_page(agent, source)
          end
        rescue Exception => e
          @@logger.log Logger::ERROR,  "Error Occured while fetching source " + source.url
          @@logger.log Logger::INFO,  e.inspect
        end
      end
      @@logger.log Logger::INFO, "Sleeping #{@@cycle_delay} seconds..."
      sleep(@@cycle_delay)
    end
  end


  #
  # parse_web_page
  # parses web page and get each entry data
  #

  def self.parse_web_page(agent, source)
    begin
      page = agent.get(source.url)
    rescue Exception => e
      @@logger.log Logger::ERROR,  "Error Fetching Content from source "+ source.url
      @@logger.log Logger::INFO,   e.inspect
      return
    end
    domain_url = page.uri.scheme+"://"+page.uri.host
    page.parser.xpath(source.links_xpath).each do |link|
      content_page = page.links_with(:href => link[:href])[0].click
      full_link = content_page.uri.to_s
      full_link += source.link_suffix

      if (!CrawlerContent.find_by_url(full_link).nil?)
        next
      end
      @@logger.log Logger::INFO,  "Sleeping #{@@inter_item_delay} seconds..."
      sleep(@@inter_item_delay)
      @@logger.log Logger::INFO,  "----> Fetching Sub-Content " + full_link
      begin
        content_title = content_page.parser.xpath(source.title_xpath).children.to_s.strip
        content_body = content_page.parser.xpath(source.body_xpath).children.to_s.strip
        thumbnail_tag = content_page.parser.xpath(source.thumbnail_xpath)[0]
        content_thumbnail_url = nil
        if (!thumbnail_tag.nil?)
          content_thumbnail_url = thumbnail_tag.attributes["src"].value
        end
      rescue Exception => e
        @@logger.log Logger::ERROR,  e
        next
      end

      # need to check if the same article in the db or not before insertion
      if !content_thumbnail_url.nil?
        content_thumbnail_url =~ @@url_regex
        domain = $2
        if domain.nil?
          content_thumbnail_url = content_thumbnail_url.gsub(1) if content_thumbnail_url.index("./") == 0
          content_thumbnail_url = "/"+content_thumbnail_url unless content_thumbnail_url[0] == '/' && domain_url[domain_url.length-1] =='/'
          content_thumbnail_url = domain_url + content_thumbnail_url
        end
      else
        content_thumbnail_url = ""
      end

      if content_title.size == 0
        next
      end

      # For Opinion Articles
      # If there is a writer name available for this source, I should add it to the title of the article
      if source.writer_name_xpath
        writer_name = content_page.parser.xpath(source.writer_name_xpath).children.to_s.strip
        @@logger.log Logger::INFO,  "There is an author name:"
        @@logger.log Logger::INFO,  "Author name: " + writer_name
      elsif source.content_type == "webpage_article"
        # try to extract title from image
        thumbnail_tag = content_page.parser.xpath(source.thumbnail_xpath)[0]
        writer_name = thumbnail_tag.attributes["alt"].value.to_s.strip unless thumbnail_tag.nil?
        writer_name = writer_name.strip unless writer_name.nil?
        @@logger.log Logger::INFO , "There is an author name:"
        @@logger.log Logger::INFO, "Author name: " + writer_name
      end

      # For tags associated with articles.
      content_tags = nil
      if source.tags_xpath
        content_tags = self.extract_tags(content_page, source)
      end

      content_title = writer_name + " :" + content_title unless writer_name.nil?

#      begin
#        content_title = Iconv.iconv("utf-8", content_page.response_header_charset[0].to_s, content_title).to_s unless content_title.nil?
#        writer_name = Iconv.iconv("utf-8", content_page.response_header_charset[0].to_s, writer_name).to_s unless writer_name.nil?
#        content_body = Iconv.iconv("utf-8", content_page.response_header_charset[0].to_s, content_body).to_s unless content_body.nil?
#        content_tags = Iconv.iconv("utf-8", content_page.response_header_charset[0].to_s, content_tags).to_s unless content_tags.nil?
#        content_title = writer_name + " :" + content_title unless writer_name.nil?
#      rescue Exception => e
#        @@logger.log Logger::ERROR,  "Error occured while inserting into database"+e
#        next
#      end

      content_thumbnail_url = self.verify_url(content_thumbnail_url)
      content = CrawlerContent.find_by_url full_link.to_s
      if (!content)
        begin
          @@logger.log Logger::INFO,  "   |--> Storing Content..."
          content = CrawlerContent.new
          content.url = full_link
          content.title = content_title
          content.thumbnail_url = content_thumbnail_url
          content.body = content_body
          content.tags = content_tags
          content.content_source = source
          content.content_type = source.content_type
          content.save!
        rescue Exception => e
          @@logger.log Logger::ERROR,  "Error occured while inserting into database"+e
          next
        end
      elsif (source.content_type == 'webpage_article' && content.content_type != source.content_type )
        begin
          @@logger.log Logger::INFO,  "   |--> Found it and updating data..."
          content.url = full_link
          content.title = content_title
          content.thumbnail_url = content_thumbnail_url
          content.body = content_body
          content.tags = content_tags
          content.content_source = source
          content.content_type = source.content_type
          content.save!
        rescue Exception => e
          @@logger.log Logger::ERROR,  "Error occured while inserting into database"+e
          next
        end
      end

      # Attempt to look for imbeded video with the content
      if source.video_parent_xpath
        atempt_video_extraction(content_page, source)
      end
      @@logger.log Logger::INFO, "----> Finished Fetching Sub-Content " + full_link
    end
  end


  #
  # parse_rss
  # parses RSS feeds and get each feed entry data
  #

  def self.parse_rss(agent, source)
    begin
      page = agent.get(source.url)
    rescue Exception => e
      @@logger.log Logger::WARN, "Error Fetching Content from source "+ source.url + ": " + e
      return
    end
    domain_url = page.uri.scheme+"://"+page.uri.host
    begin
      result = RSS::Parser.parse(page.body)
    rescue Exception => e
      @@logger.log Logger::ERROR, e
      return
    end

    if result.items.nil?
      return
    end

    result.items.each do |item|
      link = ""
      begin
        item.links.each do |l|
          if l.rel == "alternate"
            link = l.href.to_s
            break;
          end
        end
      rescue Exception => e
        link = item.link
      end

      #puts "Trying to find duplicates----------------------" + (!CrawlerContent.find_by_url(link.to_s).nil?).to_s
      if (!CrawlerContent.find_by_url(link.to_s).nil?)
        next
      end

      @@logger.log Logger::INFO, "Sleeping #{@@inter_item_delay} seconds..."
      sleep(@@inter_item_delay)
      @@logger.log Logger::INFO, "----> Fetching Sub-Content " + link
      begin
        content_page = agent.get(link)
        content_title = content_page.parser.xpath(source.title_xpath).children.to_s.strip
        content_body = content_page.parser.xpath(source.body_xpath).children.to_s.strip
        thumbnail_tag = content_page.parser.xpath(source.thumbnail_xpath)[0]
        content_thumbnail_url = nil
        if (!thumbnail_tag.nil?)
          content_thumbnail_url = thumbnail_tag.attributes["src"].value.strip
        end
        if !content_thumbnail_url.nil?
          content_thumbnail_url =~ @@url_regex
          domain = $2
          if domain.nil?
            content_thumbnail_url = content_thumbnail_url.slice(1..content_thumbnail_url.length) if content_thumbnail_url.index("./") == 0
            content_thumbnail_url = "/"+content_thumbnail_url unless content_thumbnail_url[0] == '/' || domain_url[domain_url.length-1] =='/'
            content_thumbnail_url = domain_url + content_thumbnail_url
          end
        else
          content_thumbnail_url = ""
        end
      rescue Exception => e
        @@logger.log Logger::ERROR, e
        next
      end

      if content_title.size == 0
        next
      end


      # For Opinion Articles
      # If there is a writer name available for this source, I should add it to the title of the article
      if source.writer_name_xpath
        writer_name = content_page.parser.xpath(source.writer_name_xpath).children.to_s.strip
        @@logger.log Logger::INFO,  "There is an author name:"
        @@logger.log Logger::INFO,  "Author name: " + writer_name
      elsif source.content_type == "webpage_article"
        # try to extract title from image
        thumbnail_tag = content_page.parser.xpath(source.thumbnail_xpath)[0]
        writer_name = thumbnail_tag.attributes["alt"].value.to_s.strip unless thumbnail_tag.nil?
        writer_name = writer_name.strip unless writer_name.nil?
        @@logger.log Logger::INFO , "There is an author name:"
        @@logger.log Logger::INFO, "Author name: " + writer_name
      end

      # For tags associated with articles.
      content_tags = nil
      if source.tags_xpath
        begin
          content_tags = self.extract_tags(content_page, source)
        rescue Exceptoin => e
          @@logger.log Logger::ERROR, "Error occurred while getting tags: " + e.inspect
        end
      end

      content_title = writer_name + " :" + content_title unless writer_name.nil?

#      begin
#        content_title = Iconv.iconv("utf-8", content_page.response_header_charset[0].to_s, content_title).to_s unless content_title.nil?
#        writer_name = Iconv.iconv("utf-8", content_page.response_header_charset[0].to_s, writer_name).to_s unless writer_name.nil?
#        content_body = Iconv.iconv("utf-8", content_page.response_header_charset[0].to_s, content_body).to_s unless content_body.nil?
#        content_tags = Iconv.iconv("utf-8", content_page.response_header_charset[0].to_s, content_tags).to_s unless content_tags.nil?
#        content_title = writer_name + " :" + content_title unless writer_name.nil?
#      rescue Exception => e
#        @@logger.log Logger::ERROR, "Error occurred while inserting into database: " + e.inspect
#        next
#      end

      content_thumbnail_url = self.verify_url(content_thumbnail_url)
      content = CrawlerContent.find_by_url link.to_s
      if (!content)
        begin
          @@logger.log Logger::INFO, CrawlerContent.find_all_by_url(link).inspect
          @@logger.log Logger::INFO, "   |--> Storing Content..."
          content = CrawlerContent.new
          content.url = link.to_s
          content.title = content_title
          content.thumbnail_url = content_thumbnail_url
          content.body = content_body
          content.tags = content_tags
          content.content_source = source
          content.content_type = source.content_type
          content.save!
        rescue Exception => e
          @@logger.log Logger::ERROR, "Error occurred while inserting into database: " + e.inspect
          next
        end
      elsif (source.content_type == 'webpage_article' && content.content_type != source.content_type)
        begin
          @@logger.log Logger::INFO, CrawlerContent.find_all_by_url(link).inspect
          @@logger.log Logger::INFO, "   |--> Found it and updating data..."
          content.url = link.to_s
          content.title = content_title
          content.thumbnail_url = content_thumbnail_url
          content.body = content_body
          content.tags = content_tags
          content.content_source = source
          content.content_type = source.content_type
          content.save!
        rescue Exception => e
          @@logger.log Logger::ERROR, "Error occurred while inserting into database: " + e.inspect
          next
        end
      end

      # Attempt to look for imbeded video with the content
      if source.video_parent_xpath
        atempt_video_extraction(content_page, source)
      end
      @@logger.log Logger::INFO, "----> Finished Fetching Sub-Content " + link
    end
  end

  def self.parse_articles(agent, source)

  end

  def self.atempt_video_extraction(content_page, source)

    title_tag = content_page.parser.xpath(source.title_xpath)[0]
    thumbnail_tag = content_page.parser.xpath(source.thumbnail_xpath)[0]
    parent = common_parent(title_tag, thumbnail_tag)

    if parent.nil?
      return
    end
    iframes = parent.xpath("//iframe")

    if iframes && iframes.size > 0
      iframes.each do |iframe|
        url = iframe[:src]
        if url =~ /^
          (    (https?):\/\/                            )? # 2: protocol
          (    [a-z\d]+[\-\.]([a-z\d]+)*\.[a-z]{2,6}    )  # 3: domain
          (
            (:
              (      \d{1,5}                           )  # 7: port
            )?
            (        \/.*                                 )? # 8: query
          )?
          $/ix
          query = $8 || ''
          domain = $3
          website_name = $4
          port = $7 ? $7.to_i : url.start_with?('https') ? 81 : 80
          url.insert 0, "http#{'s' if $7 == '81'}://" unless $1
          if website_name.downcase == "youtube"
            if query =~ /^ \/embed\/ ([a-zA-Z\d]+).* $/ix #  http://www.youtube.com/embed/GR1TCfCAkAE?rel=0
              video_id = $1
              # TODO insert the item in DB
              youtube_link = "http://www.youtube.com/watch?v="+video_id
              if (!CrawlerContent.find_by_url youtube_link)
                begin
                  puts "   |--> Storing Video..."
                  content = CrawlerContent.new
                  content.url = youtube_link
                  content.title = content_title
                  content.content_source = source
                  content.content_type = "video"
                  content.save!
                rescue Exception => e
                  @@logger.log Logger::ERROR, "Error occured while inserting into database" + e
                  return
                end
              end
            end
          end
        end
      end
    end

    anchors = content_page.parser.xpath(source.video_parent.xpath).xpath("//a")
    if anchors && anchors.size > 0
      youtube_regex = /^
          (    (https?):\/\/                            )? # 2: protocol
          (    [a-z\d]+[\-\.](youtube)*\.[a-z]{2,6}    )  # 3: domain
          (
            (:
              (      \d{1,5}                           )  # 7: port
            )?
            (        \/.*                                 )? # 8: query
          )?
          $/ix
      youtube_links = anchors.to_a.delete_if { |x| x[:href].nil? || (x[:href] =~ youtube_regex).nil? }

      youtube_links.each do |l|
        # TODO insert the item in DB
        if (!CrawlerContent.find_by_url l)
          begin
            @@logger.log Logger::INFO, "   |--> Storing Video..."

          rescue Exception => e
            @@logger.log Logger::ERROR, "Error occurred while inserting into database" + e
            exit 1
          end
        end
      end
    end
  end

  #
  # Find a common parent between two HTML elements
  # returns: the common parent or nil if no common parent
  #
  def self.common_parent(title_tag, thumbnail_tag)
    p = title_tag
    begin
      def p.visited=(value)
        @value = value
      end

      def p.visited
        return @value
      end

      p.visited = true
      p = defined?(p.parent) ? p.parent : nil
    end while !p.nil?

    p = thumbnail_tag
    begin
      if defined? p.visited
        break
      end
      p = defined?(p.parent) ? p.parent : nil
    end while !p.nil?

    return p
  end

  #
  # extract tags from a webpage
  #
  def self.extract_tags(content_page, source)
    if source.tags_xpath
      tags_elements = content_page.parser.xpath(source.tags_xpath)
      if !tags_elements.nil?
        tags = tags_elements.map{|e| e.children.to_s.strip }.join(",")
        @@logger.log Logger::INFO, "Found tags: " + tags
        return tags
      end
    end
    return nil
  end

  #
  # get content size
  #
  def self.get_content_size url
    if url.nil? or url.size == 0
      return 0
    else
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Head.new(uri.request_uri)
      response = http.request(request)
      # Headers are lowercased
      return response.content_length
    end
  end


  def self.verify_url url
    page = @@agent.head url
    return page.uri.to_s
  end

end

#file = File.new("links.html", "w")
#         page.links.each do |l|
#            if !l.href.nil?
#               file.write("<a href='"+l.href+"'>"+l.text()+"</a><br/>")
#            end
#         end

