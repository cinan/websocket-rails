require 'websocket_rails/data_store'

module WebsocketRails
  class BaseController
        
    def initialize
      @data_store = DataStore.new(self)
      @objects
    end
    
    def client_id
      @_message.first
    end

    def message
      @_message.last
    end

    def send_message(event, message)
      @message_counter += 1
      @_dispatcher.send_message event.to_s, [client_id,message] if @_dispatcher.respond_to?(:send_message)
    end

    def broadcast_message(event, message)
      @_dispatcher.broadcast_message event.to_s, message if @_dispatcher.respond_to?(:broadcast_message)
    end
    
    def data_store
      @data_store
    end
    
    @@observers = Hash.new {|h,k| h[k] = Array.new}
    
    # Add observer for methods, objects, and variables.
    # Add criteria for observer to trigger.
    def self.observe(event = nil, &block)
      if event
        @@observers[event] << block
      else
        @@observers[:general] << block
      end
    end
    
    def execute_observers(event)
      @@observers[:general].each do |observer|
        instance_eval( &observer )
      end
      @@observers[event].each do |observer|
        instance_eval( &observer )
      end
    end
    
  end
end