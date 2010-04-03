$:.unshift 'lib'

require 'rubygems'
require 'live/app'

file = File.dirname(__FILE__) + '/config/database.yml'

Live.start(file)

