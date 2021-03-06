module Intervention
  class Client < EventMachine::Connection
    attr_reader :server, :parser

    def inspect
      "#<Client:%s listen:%s>" % [(object_id << 1).to_s(16), Intervention.config.listen_port]
    end

    def post_init
      Intervention.clients << self
      @parser = Segregate.new(self, debug: true)
    end

    def receive_data data
      @parser.parse_data data
    end

    def on_message_complete parser
      callback :request

      if Intervention.requests_to_block.include?(@parser.path)
        self.close_connection
        Intervention.clients.delete self
        return
      end

      host = @parser.headers['host'][/([^\:]*)(?:\:|$)/,1]
      port = (@parser.headers['host'][/(?:\:)(\d+)/,1] || 80)

      @server = EventMachine.connect host, port, Intervention::Server, client: self

      @server.send_data @parser.raw_data
      Intervention.clients.delete self
    end

    def unbind
      @server.close_connection_after_writing if @server
      self.close_connection
    end

    private

    def callback event
      Intervention.event_handlers[event].call(self) if Intervention.event_handlers.key? event
      Intervention.callbacks.each { |c| c.send(event, self) if c.respond_to? event }
    end
  end
end
