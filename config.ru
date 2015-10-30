require 'rack'
require_relative 'url_shortener.rb'

class Application
  def self.call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    if req.path_info.match /\/get_short_url\/.+/
      long_url = req.path_info.sub('/get_short_url/', '')
      short_url = UrlShortener.new.get_short_url(long_url)
      res['Content-Type'] = 'application/json'
      res.write({long_url: long_url, short_url: short_url}.to_json)
    end
    res.finish
  end
end

run Application
