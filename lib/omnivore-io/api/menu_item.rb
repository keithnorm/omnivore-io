module OmnivoreIO
  class MenuItem
    include OmnivoreObject
    
    attr_accessor :client
    json_attr_accessor :id, :location_id, :name, :price, :price_levels,
      :in_stock, :modifier_groups_count
    
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

    def get_menu_items(location_id, options={})
      response = request(:get, "/locations/#{location_id}/menu/items", options)
      (response['_embedded']['menu_items'] || []).map do |menu_item_hash|
        OmnivoreIO::MenuItem.new self, menu_item_hash.merge(location_id: location_id)
      end
    end
    
    def get_menu_item(location_id, menu_item_id)
      response = request(:get, "/locations/#{location_id}/menu/items/#{menu_item_id}")
      OmnivoreIO::MenuItem.new self, response.merge(location_id: location_id)
    end

  end
end