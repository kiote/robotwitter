require 'rubygems'
require 'robotwitter'

$:.unshift File.dirname(__FILE__)

client = Robotwitter::Robot.new 'settings.yaml', 'test_login', nil
client.follow_all_back