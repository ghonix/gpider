#!/usr/bin/env ruby
require 'rubygems'        # if you use RubyGems
require 'daemons'


pwd  = File.dirname(File.expand_path(__FILE__))
file = pwd + '/runner.rb'

Daemons.run_proc("crawler") do
    exec "ruby #{file}"
end

