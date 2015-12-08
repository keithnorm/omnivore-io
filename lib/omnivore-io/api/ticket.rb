module OmnivoreIO
  class TicketItem
    include OmnivoreObject
    
    json_attr_accessor :menu_item, :quantity, :modifiers, :sent
    
    def initialize(attributes={})
      self.quantity = attributes['quantity']
      self.sent = attributes['sent']
      self.menu_item = OmnivoreIO::MenuItem.new(nil, attributes['_embedded']['menu_item'])
      self.modifiers = (attributes['modifiers'] || []).map{|modifier_json| OmnivoreIO::Modifier.new(nil, modifier_json) }
    end
    
    def as_json(options={})
      json = super
      json[:menu_item] = self.menu_item.as_json
      json
    end
    
  end
  
  class Ticket
    include OmnivoreObject
    
    attr_accessor :client
    json_attr_accessor :id, :location_id, :auto_send, :closed_at,
      :guest_count, :name, :open, :opened_at, :void, :ticket_number, :totals, :employee, :order_type, :revenue_center, :items
    
    def initialize(client, attributes={})
      self.client = client
      self.items = []
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
      (attributes['_embedded']['items'] || []).each do |item_json|
        self.items << OmnivoreIO::TicketItem.new(item_json)
      end
      self.order_type = OmnivoreIO::OrderType.new(nil, attributes['_embedded']['order_type'])
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
    
    def as_json(options={})
      json = super
      json[:items] = self.items.map{ |item| item.as_json }
      json[:order_type] = self.order_type.as_json
      json
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