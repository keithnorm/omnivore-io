module OmnivoreIO
  class Modifier
    include OmnivoreObject
    
    attr_accessor :client
    json_attr_accessor :id, :name, :price, :price_levels,
      :price_per_unit
    
    def initialize(client, attributes={})
      self.client = client
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end
    
  end
  
  class API

    def get_modifiers(location_id, options={})
      response = request(:get, "/locations/#{location_id}/menu/modifiers", options)
      (response['_embedded']['modifiers'] || []).map do |modifier_hash|
        OmnivoreIO::Modifier.new self, modifier_hash.merge(location_id: location_id)
      end
    end
    
    def get_modifier(location_id, modifier_id)
      response = request(:get, "/locations/#{location_id}/menu/modifiers/#{modifier_id}")
      OmnivoreIO::Modifier.new self, response.merge(location_id: location_id)
    end

  end
end