#!/usr/bin/env ruby
require 'lib/db.rb'
require 'lib/db_connection.rb'

array = []
counter = -1
entry = {}
file = File.new("./db/columns.txt", "r")
while (line = file.gets)
  counter = (counter + 1) % 3
  if counter == 0
    entry[:name] = line.strip
  elsif counter == 1
    entry[:url] = line.strip
  elsif counter == 2
    entry[:writers] = line.strip
    array.push entry
    entry = {}
  end
end
file.close

puts array.size

array.each do |e|
  begin
    newspaper = Newspaper.find_by_name e[:name]
    if !newspaper.nil?
      next
    end
    newspaper = Newspaper.new
    newspaper.name = e[:name]
    newspaper.url = e[:url]
    newspaper.save!
    
    e[:writers].split(',').each do |w|
      w = w.strip
      
      writer = ArticleWriter.find_by_name w
      if writer.nil?
        writer = newspaper.article_writers.new :name => w.strip
        writer.save!
      elsif writer.newspapers.find_by_url(newspaper.url).nil?
        writer.newspapers.new newspaper
      end
    end
    
  rescue Exception => e
    puts e
    exit 1
  end
end
