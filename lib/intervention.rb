require 'socket'
require 'hashie'
require 'json'
require 'uri'
require 'yaml'
require 'observer'
require 'pry'

require_relative 'intervention/version'
require_relative 'intervention/proxy'
require_relative 'intervention/proxy/transaction'
require_relative 'intervention/proxy/event_handler'

module Intervention
  Thread.abort_on_exception = true

  class << self

    # Configure Interventions default values
    #
    # Intervention.configure do |i|
    #   i.listen_port = 4000
    #   i.host_address = "www.google.com"
    # end
    #
    # [listen_port = Integer]   The default listening port for the proxy server socket
    # [host_address = String]   The default address for the forward socket to send to
    # [host_port = Integer]     The default port number for the forward socket to send to
    # [auto_start = Boolean]    Whether to automaticly start the proxy upon creation
    #
    def configure
      yield config
    end

    # Creates a new proxy object
    # yields the configuration block if one is present
    # @param name [String] the given name of the proxy
    # Keyword Arguments:
    # @param listen_port [Integer] The default listening port for the proxy server socket
    # @param host_address [Hash] The default address for the forward socket to send to
    # @param host_port [Integer] host_port The default port number for the forward socket to send to
    # @returns [Proxy] the new proxy object
    #
    # Intervention.new "my_proxy", listen_port: 4000, host_address: "www.google.com"
    #
    # Intervention.new "my_proxy" do
    #   configure do |p|
    #     p.listen_port = 4000
    #     p.host_address = "www.google.com"
    #   end
    # end
    #
    def new name, **kwargs, &block
      if proxies.has_key? name
        raise NameError, 'A Proxy with this name already exists!'
      else
        proxies[name.to_sym] = Proxy.new name, **kwargs, &block
      end
    end

    # Start all proxies within Intervention
    #
    def start_all
      proxies.each { |name, proxy| proxy.start }
    end

    # Stop all proxies within Intervention
    #
    def stop_all
      proxies.each { |name, proxy| proxy.stop }
    end

    def proxy proxy_name
      proxies[proxy_name.to_sym]
    end

    def config
      @config ||= Hashie::Mash.new
    end

    # Proxies stores a list of all current proxies
    # @returns [Array] of all the current proxies
    #
    def proxies
      config.proxies ||= Hashie::Mash.new
    end
  end
end

Intervention.configure do |config|
  config.listen_port  = 3000
  config.host_address = 'localhost'
  config.host_port    = 80
  config.auto_start   = false
end