module OmnivoreIO
  class Location
    
    attr_accessor :id, :address, :name, :phone, :website
    
    def initialize(attributes={})
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
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
        OmnivoreIO::Location.new location_hash
      end
    end
    
    def get_location(location_id)
      response = request(
        :get,
        "/locations/#{location_id}/"
      )
      OmnivoreIO::Location.new response
    end

  end
end