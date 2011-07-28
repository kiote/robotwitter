$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'twitter'
require 'rspec'
require 'fakeweb'
require 'robotwitter'