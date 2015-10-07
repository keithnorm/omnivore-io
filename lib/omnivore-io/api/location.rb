module OmnivoreIO
  class Location
    include OmnivoreObject
    
    attr_accessor :client
    json_attr_accessor :id, :address, :name, :phone, :website, :status
    
    def initialize(client, attributes={})
      self.client = client
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end
    
    def menu_items(options={})
      client.get_menu_items(self.id, options)
    end
    
    def order_types(options={})
      client.get_order_types(self.id, options)
    end
    
    def tickets(options={})
      client.get_tickets(self.id, options)
    end
    
    def online?
      self.status == 'online'
    end
    
  end
  
  class API

    def get_locations(options={})
      response = request(
        :get,
        '/locations',
        options
      )
      (response['_embedded']['locations'] || []).map do |location_hash|
        OmnivoreIO::Location.new self, location_hash
      end
    end
    
    def get_location(location_id)
      response = request(
        :get,
        "/locations/#{location_id}"
      )
      OmnivoreIO::Location.new self, response
    end

  end
end