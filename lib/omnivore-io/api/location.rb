module OmnivoreIO
  class Location
    attr_accessor :client
    attr_accessor :id, :address, :name, :phone, :website
    
    def initialize(client, attributes={})
      self.client = client
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end
    
    def order_types
      response = client.request(:get, "/locations/#{self.id}/order_types")
      response['_embedded']['order_types'].map do |order_type_hash|
        OmnivoreIO::OrderType.new self.client, order_type_hash.merge(location_id: self.id)
      end
    end
    
    def tickets
      response = client.request(:get, "/locations/#{self.id}/tickets")
      response['_embedded']['tickets'].map do |ticket_hash|
        OmnivoreIO::Ticket.new self.client, ticket_hash.merge(location_id: self.id)
      end
    end
    
  end
  
  class API

    def get_locations
      response = request(
        :get,
        '/locations'
      )
      response['_embedded']['locations'].map do |location_hash|
        OmnivoreIO::Location.new self, location_hash
      end
    end
    
    def get_location(location_id)
      response = request(
        :get,
        "/locations/#{location_id}/"
      )
      OmnivoreIO::Location.new self, response
    end

  end
end