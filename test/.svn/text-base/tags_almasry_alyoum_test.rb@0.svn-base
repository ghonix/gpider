require "test/unit"
require 'rubygems'
require 'mechanize'
require 'logger'
require 'rss'
require './lib/db_connection.rb'
require './lib/db.rb'

class TestTags < Test::Unit::TestCase
  @pwd = File.dirname(File.expand_path(__FILE__))
  @articles = []
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    agent = Mechanize.new { |a| a.log = Logger.new(@pw + "../log/mechanize.log") }
    agent.user_agent_alias = "Linux Firefox"

    page = agent.get("http://www.almasryalyoum.com/rss_feed_term/2/rss.xml")
    begin
      result = RSS::Parser.parse(page.body)
    rescue Exception => e
      puts e
      return
    end

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  def test_tags

  end


  # Fake test
  def test_fail

    # To change this template use File | Settings | File Templates.
    fail("Not implemented")
  end
end