require 'socket'
require 'hashie'
require 'json'
require 'uri'
require 'yaml'

require 'intervention/proxy'
require 'intervention/transaction'

# requires all files within the interventions folder if it exists
if File.directory? './interventions'
  Dir["./interventions/*.rb"].each {|file| require file }
end

module Intervention
  Thread.abort_on_exception=true

  class << self
    attr_accessor :listen_port, :host_address, :host_port, :auto_start

    # Starts intervention from a config file
    #
    def boot config_file = nil
      config = YAML.load_file config_file || "./config/intervention.yml"
      config.each do | proxy_name, proxy_options |
        new_proxy proxy_name, proxy_options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end
    end

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
      yield self
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
    # Intervention.new_proxy "my_proxy", listen_port: 4000, host_address: "www.google.com"
    #
    # Intervention.new_proxy "my_proxy" do |proxy|
    #   proxy.listen_port = 4000
    #   proxy.host_address = "www.google.com"
    # end
    #
    def new_proxy name, **kwargs
      proxy = Proxy.new name, kwargs
      proxies << proxy
      yield proxy if block_given?
      proxy.start if Intervention.auto_start || kwargs[:auto_start]
      proxy
    end

    # Start all proxies within Intervention
    #
    def start_all
      proxies.each { |proxy| proxy.start }
    end

    # Stop all proxies within Intervention
    #
    def stop_all
      proxies.each { |proxy| proxy.stop }
    end

    # Proxies stores a list of all current proxies
    # @returns [Array] of all the current proxies
    #
    def proxies
      @proxies ||= []
    end
  end
end

Intervention.configure do |config|
  config.listen_port  = 3000
  config.host_address = 'localhost'
  config.host_port    = 80
  config.auto_start   = true
end