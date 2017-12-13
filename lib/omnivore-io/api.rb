require 'rest-client'
require 'json'

__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
  $LOAD_PATH.unshift(__LIB_DIR__)
end

require "omnivore-io/api/errors"
require "omnivore-io/api/version"

module OmnivoreIO
  module OmnivoreObject

    def self.included base
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :_json_attributes

      def json_attr_accessor(*attributes)
        self._json_attributes = attributes
        attributes.each do |attribute|
          attr_accessor attribute
        end
      end
    end

    module InstanceMethods

      def as_json(options={})
        json = {}
        self.class._json_attributes.each do |attr|
          val = self.send attr
          json[attr] = val
        end
        json
      end

      def merge!(object)
        self.class._json_attributes.each do |attr|
          if object.respond_to?(attr)
            if val = object.send(attr)
              self.send "#{attr}=".to_sym, val
            end
          end
        end
      end

    end

  end

  class API

    HEADERS = {
      :content_type => :json,
      :accept => :json,
      :'Api-Key' => 'API_KEY_HERE'
    }

    OPTIONS = {
      :host => 'https://api.omnivore.io/',
      :api_version => '1.0'
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
        url = "#{OPTIONS[:host]}#{OPTIONS[:api_version]}#{endpoint}"
        if query.keys.length
          url << "?"
          url << URI.encode_www_form(query)
        end
        RestClient.get url, headers
      when :post
        url = "#{OPTIONS[:host]}#{OPTIONS[:api_version]}#{endpoint}"
        payload = query.as_json.to_json
        RestClient::Request.execute(method: :post, url: url, payload: payload, headers: headers)
      end
      # TODO: handle errors
      JSON.parse(response.to_str)
    end

  end
end

require "omnivore-io/api/location"
require "omnivore-io/api/menu_item"
require "omnivore-io/api/modifier"
require "omnivore-io/api/order_type"
require "omnivore-io/api/ticket"
