module OmnivoreIO
  class OrderType
    attr_accessor :client
    attr_accessor :id, :location_id, :available, :name
    
    def initialize(client, attributes={})
      self.client = client
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end
    
  end
end