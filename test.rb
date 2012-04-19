
pwd  = File.dirname(File.expand_path(__FILE__))

require pwd + '/lib/crawler.rb'
require 'rubygems'
require 'mechanize'
require 'logger'
require 'rss'
require './lib/db_connection.rb'
require './lib/db.rb'
agent = Mechanize.new { |a| a.log = Logger.new("./log/mechanize.log") }
agent.user_agent_alias = "Linux Firefox"


sources = CrawlerContent.find :all, :conditions => "title like '%بالفيديو%'"
sources. each { |s|
  page = agent.get s.url
  Crawler.atempt_video_extraction page, s.content_source
}

