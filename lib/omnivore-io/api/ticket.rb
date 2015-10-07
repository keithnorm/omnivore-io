module OmnivoreIO
  class Ticket
    include OmnivoreObject
    
    attr_accessor :client
    json_attr_accessor :id, :location_id, :auto_send, :closed_at,
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
  
  class API

    def get_tickets(location_id, options={})
      response = request(:get, "/locations/#{location_id}/tickets", options)
      (response['_embedded']['tickets'] || []).map do |ticket_hash|
        OmnivoreIO::Ticket.new self, ticket_hash.merge(location_id: location_id)
      end
    end
    
    def get_ticket(location_id, ticket_id)
      response = request(:get, "/locations/#{location_id}/tickets/#{ticket_id}")
      OmnivoreIO::Ticket.new self, response.merge(location_id: location_id)
    end

  end
end