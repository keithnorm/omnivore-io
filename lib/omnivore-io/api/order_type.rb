module OmnivoreIO
  class OrderType
    include OmnivoreObject
    
    attr_accessor :client
    json_attr_accessor :id, :location_id, :available, :name
    
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

    def get_order_types(location_id, options={})
      response = request(:get, "/locations/#{location_id}/order_types", options)
      (response['_embedded']['order_types'] || []).map do |order_type_hash|
        OmnivoreIO::OrderType.new self, order_type_hash.merge(location_id: location_id)
      end
    end

  end
end