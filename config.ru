require 'bundler'
Bundler.require

require File.expand_path '../app.rb', __FILE__

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == ENV['USERNAME'] and password == ENV['PASSWORD']
end

require './app'
run PydepsAPI
