#!/usr/bin/env ruby




pwd  = File.dirname(File.expand_path(__FILE__))

require 'rubygems'
require 'mechanize'
require 'logger'
require 'rss'
require pwd + '/db_connection.rb'
require pwd + '/db.rb'

training_records = CrawlerContent.limit CrawlerContent.count/2

