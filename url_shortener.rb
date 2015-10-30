require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= 'Gemfile'
ENV['GOOGLE_API_KEY'] ||= ''
require 'bundler/setup'
require 'google/api_client'

class UrlShortener
  def initialize
    @client = Google::APIClient.new(application_name: 'MTVWorld', application_version: '1.0',
                                    key: ENV['GOOGLE_API_KEY'], authorization: nil)
    @service = @client.discovered_api('urlshortener')
  end

  def api_key
    ENV['GOOGLE_API_KEY']
  end

  def batch
    @results ||= []
    @batch ||= Google::APIClient::BatchRequest.new do |result|
      @results << result.data['id'] if result.data
    end
    @batch
  end

  def get_short_url(long_url)
    @results = []
    batch.add(:api_method => @service.url.insert,
              :body_object => {'longUrl' => long_url})
    handle_timeouts do
      @client.execute(batch)
    end
    @results[0] if @results.any?
  end

  def handle_timeouts
    begin
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout
      {}
    end
  end
end
