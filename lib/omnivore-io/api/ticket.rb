module OmnivoreIO
  class Ticket
    include OmnivoreObject
    
    attr_accessor :client, :items
    json_attr_accessor :id, :location_id, :auto_send, :closed_at,
      :guest_count, :name, :open, :opened_at, :ticket_number, :totals, :employee, :order_type, :revenue_center
    
    def initialize(client, attributes={})
      self.client = client
      self.items = []
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end
    
    def open!
      payload = {
        "employee" => self.employee,
        "order_type" => self.order_type,
        "revenue_center" => self.revenue_center,
        "guest_count" => self.guest_count,
        "name" => self.name,
        "auto_send" => self.auto_send
      }
      self.merge! self.client.open_ticket(self.location_id, payload)
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
    
    def open_ticket(location_id, ticket_json)
      response = request(:post, "/locations/#{location_id}/tickets", ticket_json)
      OmnivoreIO::Ticket.new self, response.merge(location_id: location_id)
    end
    
    def void_ticket(location_id, ticket_id)
      response = request(:post, "/locations/#{location_id}/tickets/#{ticket_id}", {"void": true})
      OmnivoreIO::Ticket.new self, response.merge(location_id: location_id)
    end
    
    def add_menu_item_to_ticket(location_id, ticket_id, payload_json)
      response = request(:post, "/locations/#{location_id}/tickets/#{ticket_id}/items", payload_json)
      OmnivoreIO::Ticket.new self, response.merge(location_id: location_id)
    end
    
    def add_payment_to_ticket(location_id, ticket_id, payload_json)
      response = request(:post, "/locations/#{location_id}/tickets/#{ticket_id}/payments", payload_json)
      response
    end

  end
end