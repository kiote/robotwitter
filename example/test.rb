require 'rubygems'
require 'robotwitter'

$:.unshift File.dirname(__FILE__)

client = Robotwitter::Robot.new(path_to_settigs, 'test_login') do
  'hi'
end

client.follow_all_back
