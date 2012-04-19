require 'lib/db.rb'
require 'lib/db_connection.rb'

class Script < ActiveRecord::Migration
   def self.up
      
      # Creating ContentSources table
      begin
         create_table :ContentSources do |t|
            t.string          :url
            t.boolean         :mobile,  :default => false
            t.boolean         :visited, :default => false
            t.string          :links_xpath
            t.string          :title_xpath
            t.string          :body_xpath
            t.string          :thumbnail_xpath
            t.integer         :source_type                  # Web => 0, RSS => 1
         end
      rescue Exception => e
         puts e
      end
            
      begin
         create_table :crawler_contents do |t|
            t.string          :url
            t.string          :title
            t.string          :thumbnail_url
            t.text            :body
            t.integer         :page_size, :defult => 0
            t.integer         :content_source_id, :null => false
            t.timestamps
         end      
      rescue Eception => e
         puts e
      end
      
   end
   
   def self.down
      # Dropping table ContentSources
      drop_table :ContentSources
      drop_table :crawler_contents
   end
end


### entry point

option = ARGV[0]
message = "Usage: ruby create.rb [up|down]"
if option.nil?   
   puts message
   exit 1
elsif option != "up" && option != "down"
   puts "here"
   puts message
   exit 1
end

if option == "up"
   Script.up
elsif option == "down"
   Script.down
end
