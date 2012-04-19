#!/usr/bin/env ruby

pwd  = File.dirname(File.expand_path(__FILE__))
# insert news sources in db
require pwd + '/../lib/db.rb'
require pwd + '/../lib/db_connection.rb'

# source_type => [ (0,web), (1,rss) ]

[ {
    :url => "http://www.masrawy.com/news/egypt/politics/",
    :mobile => false,
    :links_xpath => "//div[@class='CON']/div/div/a",
    :title_xpath => "//div[@id='artical']/h1",
    :body_xpath => "//div[@id='artical']/div[@id='content']",
    :thumbnail_xpath => "//div[@id='artical']/div[@class='caption']/img",
    :source_type => 0,         # Web
    :content_type => "webpage"
  },
  {
    :url => "http://www.shorouknews.com/RssFeed.aspx?folderid=284",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//div[@class='wrapper']/div[@class='innerContentSection']/div[@class='right']/div[@class='title']/div[@class='right']/h1",
    :body_xpath => "//div[@class='wrapper']/div[@class='innerContentSection']/div[@class='right']/div[@class='content']/p",
    :thumbnail_xpath => "//div[@class='wrapper']/div[@class='innerContentSection']/div[@class='right']/div[@class='content']/div[@class='leftContent']/div/img",
    :source_type => 1,         # RSS
    :content_type => "webpage",
    :video_container_xpath => "//div[@class='wrapper']/div[@class='innerContentSection']/div[@class='right']/div[@class='content']"
  },
  {
    :url => "http://www.aljazeera.net/AljazeeraRss/Rss.aspx?URL=RSS-EgyptFreedom.xml",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//span[@id='ReadWriteMetadataPlaceholder1']/span",
    :body_xpath => "//span[@id='Htmlplaceholdercontrol1']",
    :thumbnail_xpath => "//span[@id='Htmlplaceholdercontrol1']//img",
    :source_type => 1,
    :content_type => "webpage"
  },
  {
    :url => "http://www.dostor.org/politics-news-feed",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//div[@id='article_title']",
    :body_xpath => "//div[@id='content_wrapper']/div/div[@class='content']/p",
    :thumbnail_xpath => "//div[@id='content_wrapper']/div/div[@class='content']/div/div/div/a/img",
    :source_type => 1,
    :content_type => "webpage"
  },
  {
    :url => "http://www.almasryalyoum.com/rss_feed_term/2/rss.xml",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//div[@class='inside']/div[@class='panel-pane pane-node-title']/div",
    :body_xpath => "//div[@class='inside']/div[@class='panel-pane pane-node-body']/div[@class='pane-content']/p",
    :thumbnail_xpath => "//div[@class='slide-inner clear-block border']/a/img",
    :source_type => 1,
    :content_type => "webpage"
  },
  {
    :url => "http://tahrirnews.com/feed/rss/",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//div[@class='wrapper']/div[@class='mainContent innerPageNews']/h1/strong",
    :body_xpath => "//div[@class='wrapper']/div[@class='mainContent innerPageNews']/div[@class='fullRightArea']/div[@class='innerPageContent']/div[@class='text']",
    :thumbnail_xpath => "//div[@class='wrapper']/div[@class='mainContent innerPageNews']/div[@class='fullRightArea']/div[@class='innerPageContent']/div[@class='image']/img",
    :source_type => 1,
    :content_type => "webpage"
  },
  {
    :url => "http://tahyyes.blogspot.com/feeds/posts/default",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//div[@class='post hentry']/h3/a",
    :body_xpath => "//div[@class='post hentry']/div[@class='post-body entry-content']/div",
    :thumbnail_xpath => "//div[@id='HTML10']/div/img",
    :source_type => 1,
    :content_type => "blog"
  },
  {
    :url => "http://tahrirnews.com/category/%D9%85%D9%82%D8%A7%D9%84%D8%A7%D8%AA/",
    :mobile => false,
    :links_xpath => "//blockquote[@id='newsticker-jcarousellite2']/ul/li/span[@class='text']/a",
    :title_xpath => "//div[@class = 'mainContent innerPageNews']/h1/strong",
    :body_xpath => "//div[@class = 'mainContent innerPageNews']//div[@class='text']//p",
    :thumbnail_xpath => "//div[@class = 'mainContent innerPageNews']/div[@class='fullRightArea']/div[@class='innerPageContent']/div[@class='image']//img",
    :source_type => 0,
    :content_type => "webpage_article"
  },
  {
    :url => "http://www.shorouknews.com/Columns/",
    :mobile => false,
    :links_xpath => "//div[@class='grayContent']/div[@class='otherColumns']/ul/li/a",
    :title_xpath => "//div[@class='postArticle']/h2",
    :body_xpath => "//div[@class='postArticle']/p",
    :thumbnail_xpath => "//div[@class='postArticle']//div[@class='avatar']/img",
    :source_type => 0,
    :content_type => "webpage_article"
  },
  {
    :url => "http://alaaalaswany.maktoobblog.com/feed/rss/",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//div[@class='middle']/div[@class='post']//h1/a",
    :body_xpath => "//div[@class='middle']/div[@class='post']/div[@class='entry']/p",
    :thumbnail_xpath => "//li[@id='%d9%85%d8%b9%d9%84%d9%88%d9%85%d8%a7%d8%aa%d9%8a']/div[@class='sidebarprofile']//img",
    :source_type => 1,
    :content_type => "blog"
  },
  {
    :url => "http://www.ahram.org.eg/60/Al-Mashhad-Al-Syiassy.html",
    :mobile => false,
    :links_xpath => "//div[@id='OuterNews']//a",
    :title_xpath => "//span[@id='txtTitle']",
    :body_xpath => "//span[@id='txtBrief'] | //div[@id='txtBody']//p",
    :thumbnail_xpath => "//div[@id='NewsImage']/div[@id='divImages']//img",
    :source_type => 0,
    :content_type => "webpage"
  },
  {
    :url => "http://www.ahram.org.eg/11/Columns.html",
    :mobile => false,
    :links_xpath => "//div[@id='OuterNews']//td[@class='title_list']/a",
    :title_xpath => "//span[@id='txtTitle']",
    :body_xpath => "//div[@id='txtBody']//p",
    :thumbnail_xpath => "//div[@id='WriterImage']//img",
    :writer_name_xpath => "",
    :source_type => 0,
    :content_type => "webpage_article"
  },
  {
    :url => "http://www.almasryalyoum.com/opinion-channel/83",
    :mobile => false,
    :links_xpath => "//div[@id='center']/div/div[@class='view-content']/div/div[@class='views-field-title']/span[@class='field-content']/a",
    :title_xpath => "//div[@class='panel-pane pane-node-title']/div",
    :body_xpath => "//div[@class='panel-pane pane-node-body']//p",
    :thumbnail_xpath => "//div[@class='views-field-field-staff-photo-fid']/span/img",
    :writer_name_xpath => "//div[@class='view view-field-author view-id-field_author view-display-id-default view-dom-id-1']//div[@class='views-field-title']//a",
    :source_type => 0,
    :content_type => "webpage_article"
  },
  {
    :url => "http://elfagr.org/rss.aspx?secidMenu=1",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//td[@id='ctl00_ContentPlaceHolder1_maintd']//h1",
    :body_xpath => "//td[@id='ctl00_ContentPlaceHolder1_maintd']//div | //td[@id='ctl00_ContentPlaceHolder1_maintd']//p",
    :thumbnail_xpath => "//td[@id='ctl00_ContentPlaceHolder1_maintd']//img",
    :source_type => 1,
    :content_type => "webpage"
  },
  {
    :url => "http://youm7.com/NewsSection.asp?SecID=65",
    :mobile => false,
    :links_xpath => "//div[@id='sectionNewsList']//a",
    :title_xpath => "//div[@id='newsStory']/div[@id='newsStoryHeader']/h2",
    :body_xpath => "//div[@id='newsStory']/div[@id='newsStoryTxt']/p",
    :thumbnail_xpath => "//div[@id='newsStory']/div[@id='newsStoryImg']/img",
    :source_type => 0,
    :content_type => "webpage"
  },
  {
      :url => "http://www.rosaonline.net/RSS/Category.asp?id=365",
      :mobile => false,
      :links_xpath => "",
      :title_xpath => "//td[@class='BodyCell']//h1[@class='headCell']",
      :body_xpath => "//td[@class='BodyCell']//p[@align='justify']",
      :thumbnail_xpath => "//table[@class='InnerGalleryArea']//img",
      :source_type => 1,
      :content_type => "webpage",
      :link_suffix => ""

  },
    {
        :url => "http://ara.reuters.com/news/topNews",
        :mobile => false,
        :links_xpath => "//div[@class='contentBand']/div[@class='primaryContent']//a",
        :title_xpath => "//div[@class='contentBand']/div[@class='article primaryContent']/h1",
        :body_xpath => "//div[@class='contentBand']/div[@class='article primaryContent']//p",
        :thumbnail_xpath => "//div[@class='contentBand']/div[@class='article primaryContent']//img",
        :source_type => 0,
        :content_type => "webpage",
        :link_suffix => "?sp=true"

    },
    {
        :url => "http://www.bbc.co.uk/arabic/middleeast/index.xml",
        :mobile => false,
        :links_xpath => "",
        :title_xpath => "//div[@id='blq-content']//div[@class=' g-w20 g-first']//h1",
        :body_xpath => "//div[@id='blq-content']//div[@class=' g-w20 g-first']//div[@class='g-container story-body']/div[@class='bodytext']/p",
        :thumbnail_xpath => "//div[@id='blq-content']//div[@class=' g-w20 g-first']//div[@class='g-container story-body']/div[@class='bodytext']//img",
        :source_type => 1,
        :content_type => "webpage",
        :link_suffix => ""

    },
    {
        :url => "http://www.sandmonkey.org/feed/",
        :mobile => false,
        :links_xpath => "",
        :title_xpath => "//div[@id='content']//h1[@class='entry-title']",
        :body_xpath => "//div[@id='content']//div[@class='entry-content']",
        :thumbnail_xpath => "//div[@id='content']//div[@class='entry-content']//img",
        :source_type => 1,
        :content_type => "blog",
        :link_suffix => ""

    },
    {
        :url => "http://www.manalaa.net/rss.xml",
        :mobile => false,
        :links_xpath => "",
        :title_xpath => "//div[@id='squeeze']//div[@class='left-corner']/h2",
        :body_xpath => "//div[@id='squeeze']//div[@class='left-corner']//div[@class='content clear-block']",
        :thumbnail_xpath => "//img[@id='logo']",
        :source_type => 1,
        :content_type => "blog",
        :link_suffix => ""

    },
    {
        :url => "http://waelk.net/rss.xml",
        :mobile => false,
        :links_xpath => "",
        :title_xpath => "//div[@class='section']//h1[@class='title']",
        :body_xpath => "//div[@class='section']//div[@class='node node-type-story node-promoted build-mode-full clearfix']//div[@class='content']",
        :thumbnail_xpath => "//div[@id='header']//img",
        :source_type => 1,
        :content_type => "blog",
        :link_suffix => ""

    }
]
[
  {
    :url => "http://shorouknews.com/egypt/parliament-rev/rss",
    :mobile => false,
    :links_xpath => "",
    :title_xpath => "//div[@class='wrapper']/div[@class='innerContentSection']/div[@class='right']/div[@class='title']/div[@class='right']/h1",
    :body_xpath => "//div[@class='wrapper']/div[@class='innerContentSection']/div[@class='right']/div[@class='content']/p",
    :thumbnail_xpath => "//div[@class='wrapper']/div[@class='innerContentSection']/div[@class='right']/div[@class='content']/div[@class='leftContent']/div/img",
    :source_type => 1,         # RSS
    :content_type => "webpage",
    :video_container_xpath => "//div[@class='wrapper']/div[@class='innerContentSection']/div[@class='right']/div[@class='content']"
  }
].each do |l|
   begin
      if(ContentSource.find_all_by_url(l[:url]).size == 0)
         ContentSource.new(l).save
      end
   rescue Exception => e
      puts e
      next
   end
end


