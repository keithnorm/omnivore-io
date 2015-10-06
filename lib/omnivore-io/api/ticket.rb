module OmnivoreIO
  class Ticket
    attr_accessor :client
    attr_accessor :id, :location_id, :auto_send, :closed_at,
      :guest_count, :name, :open, :opened_at, :ticket_number, :totals
    
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