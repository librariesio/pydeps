require 'sinatra/base'
require './pydeps'
require 'json'

class PydepsAPI < Sinatra::Base
  get '/:name/:version.json' do
    content_type :json
    pydeps = Pydeps::Resolver.new(params[:name], params[:version])
    if pydeps.find_dependencies && pydeps.find_dependencies != "err"
      pydeps.to_json
    else
      {error: "Can't calculate dependencies for #{params[:name]} #{params[:version]}"}.to_json
    end
  end

  get '/' do
    'pydeps'
  end
end
