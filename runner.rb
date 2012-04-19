#!/usr/bin/env ruby

pwd  = File.dirname(File.expand_path(__FILE__))

require 'rubygems'
require pwd + '/lib/crawler.rb'

# run the acutal crawler
Crawler.run

