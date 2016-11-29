require 'bundler'
Bundler.require

require File.expand_path '../app.rb', __FILE__

if ENV['USERNAME'] && ENV['PASSWORD']
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == ENV['USERNAME'] and password == ENV['PASSWORD']
  end
end

require './app'
run PydepsAPI
