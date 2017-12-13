module OmnivoreIO
  class TicketItem
    include OmnivoreObject

    json_attr_accessor :menu_item, :quantity, :id, :name, :price, :sent, :sent_at, :split
    attr_accessor :client

    def initialize(client, attributes={})
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
      self.menu_item = OmnivoreIO::MenuItem.new(nil, attributes['_embedded']['menu_item'])
    end

    def as_json(options={})
      json = super
      json[:menu_item] = self.menu_item.as_json
      json
    end

  end

  class Employee

    include OmnivoreObject

    json_attr_accessor :check_name, :first_name, :id, :last_name, :login, :middle_name, :pos_id
    attr_accessor :client

    def initialize(client, attributes)
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end

  end

  class RevenueCenter

    include OmnivoreObject

    json_attr_accessor :default, :id, :name, :pos_id
    attr_accessor :client

    def initialize(client, attributes)
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end
  end

  class ServiceCharge

    include OmnivoreObject

    json_attr_accessor :comment, :id, :name, :price
    attr_accessor :client

    def initialize(client, attributes)
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end

  end


  class Total
    include OmnivoreObject

    json_attr_accessor :discounts, :due, :items, :other_charges, :paid, :service_charges, :sub_total, :tax, :tips, :total
    attr_accessor :client

    def initialize(client, attributes)
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end
  end

  class TenderType
    include OmnivoreObject

    json_attr_accessor :allows_tips, :id, :name, :pos_id
    attr_accessor :client

    def initialize(client, attributes)
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end
  end

  class Payment
    include OmnivoreObject

    json_attr_accessor :id, :tender_type, :amount, :change, :comment, :full_name, :last4, :tip, :type
    attr_accessor :client

    def initialize(client, attributes)
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
      if embedded = attributes['_embedded']
        self.tender_type = TenderType.new(client, embedded['tender_type'])
      end
    end

    def as_json(options={})
      json = super
      json[:tender_type] = self.tender_type.as_json
      json
    end


  end

  class Discount
    include OmnivoreObject
    attr_accessor :client
    json_attr_accessor :applies_to, :available, :id, :max_amount, :max_percent, :min_amount, :min_percent, :min_ticket_total, :name, :open, :pos_id, :type, :value

    def initialize(client, attributes={})
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
    end

  end

  class TicketDiscount
    include OmnivoreObject
    attr_accessor :client
    json_attr_accessor :id, :comment, :name, :value, :discount

    def initialize(client, attributes={})
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
      if embedded = attributes['_embedded']
        self.discount = Discount.new(client, embedded['discount'])
      end
    end

    def as_json(options={})
      json = super
      json[:discount] = self.discount.as_json
      json
    end

  end

  class Ticket
    include OmnivoreObject

    attr_accessor :client
    json_attr_accessor :id, :location_id, :auto_send, :closed_at,
      :guest_count, :name, :open, :opened_at, :void, :ticket_number, :totals, :employee, :order_type, :revenue_center, :items,
      :service_charges, :payments, :discounts

    def initialize(client, attributes={})
      self.client = client
      self.items = []
      attributes.each do |key, value|
        if self.respond_to? "#{key}=".to_sym
          self.send "#{key}=".to_sym, value
        end
      end
      self.totals = Total.new(client, attributes['totals'])
      if embedded = attributes['_embedded']
        (embedded['items'] || []).each do |item_json|
          self.items << OmnivoreIO::TicketItem.new(client, item_json)
        end
        self.order_type = OmnivoreIO::OrderType.new(nil, embedded['order_type'])
        self.employee = Employee.new(client, embedded['employee'])
        self.revenue_center = RevenueCenter.new(client, embedded['revenue_center'])
        self.service_charges = embedded['service_charges'].map do |service_charge|
          ServiceCharge.new(client, service_charge)
        end
        self.payments = embedded['payments'].map do |payment|
          Payment.new(client, payment)
        end
        self.discounts = embedded['discounts'].map do |discount|
          TicketDiscount.new(client, discount)
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

    def as_json(options={})
      json = super
      json[:items] = self.items.map &:as_json
      json[:order_type] = self.order_type.as_json
      json[:employee] = self.employee.as_json
      json[:revenue_center] = self.revenue_center.as_json
      json[:service_charges] = self.service_charges.map &:as_json
      json[:totals] = self.totals.as_json
      json[:payments] = self.payments.map &:as_json
      json[:discounts] = self.discounts.map &:as_json
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
