$:.unshift 'lib'

require 'rubygems'
require 'live/app'

desc "Start Rack server"
task :start do
  sh "rackup config.ru"
end

namespace :db do

  task :config do
    file = File.dirname(__FILE__) + '/config/database.yml'
    Live.configure(file)
  end

  desc "test connection"
  task :connect => [:config] do
    connect_database(@dbconfig)
  end

  desc "drop tables"
  task :drop => [:connect] do
    Live::User.drop_table rescue nil
    Live::Script.drop_table rescue nil
    Live::Track.drop_table rescue nil
  end

  desc "create tables"
  task :migrate => [:drop] do
    Live::User.create_table
    Live::Script.create_table
    Live::Track.create_table
  end

  task :login do
    #MainController.user_login(:login=>'-----', :password=>'-----')
  end

  desc "prime database with fake records"
  task :prime => [:config] do
    Live::Script.create(:name=>"hello", :version=>1, :owner=>"trans", :code=>"puts 'Hello, World!'", :modifier=>"trans", :created=>Time.now-1000)
    Live::Script.create(:name=>"bye", :version=>1, :owner=>"trans", :code=>"puts 'Bye, World!'", :modifier=>"trans", :created=>Time.now)
  end

end

