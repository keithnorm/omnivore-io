require 'rest_client'
require 'json'

__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
  $LOAD_PATH.unshift(__LIB_DIR__)
end

require "omnivore-io/api/errors"
require "omnivore-io/api/version"

require "omnivore-io/api/location"

module OmnivoreIO
  class API

    HEADERS = {
      :content_type => :json,
      :'Api-Key' => 'API_KEY_HERE'
    }

    OPTIONS = {
      :host     => 'https://api.omnivore.io/0.1'
    }

    def initialize(options={})
      options = OPTIONS.merge(options)

      @api_key = options.delete(:api_key) || ENV['OMNIVORE_IO_API_KEY']
    end

    def api_key
      @api_key
    end

    def request(method, endpoint, query={}, headers={})
      headers.merge!({ 'content_type' => :json, 'Api-Key' => self.api_key })
      response = case method
      when :get
        url = "#{OPTIONS[:host]}#{endpoint}"
        # TODO: merge query params
        RestClient.get url, headers
      when :post
        throw 'todo'
      end
      # TODO: handle errors
      JSON.parse(response.to_str)
    end

  end
end