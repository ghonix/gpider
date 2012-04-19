#
# Crawler Class
# Class that manages crawling the websites/ inserting values in database
#

pwd  = File.dirname(File.expand_path(__FILE__))

require 'rubygems'
require pwd + '/db_connection.rb'
require pwd + '/db.rb'

last_id = 0

while (records = CrawlerContent.find(:all, :select => "id, body", :conditions => "id > #{last_id} limit 200")).size > 0

end

