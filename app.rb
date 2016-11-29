require 'sinatra/base'
require './pydeps'
require 'json'

class PydepsAPI < Sinatra::Base
  get '/:name/:version.json' do
    content_type :json
    pd = Pydeps::Resolver.new(params[:name], params[:version])
    if pd.find_dependencies && pd.find_dependencies != "err"
      pd.find_dependencies.to_json
    else
      {error: "Can't calculate dependencies for #{params[:name]} #{params[:version]}"}.to_json
    end
  end
end
