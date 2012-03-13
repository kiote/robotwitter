require 'rubygems'
require 'robotwitter'

$:.unshift File.dirname(__FILE__)

client = Robotwitter::Robot.new path_to_settigs, 'test_login', nil
client.follow_all_back
