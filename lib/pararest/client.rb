require 'singleton'
require 'faraday'
require 'typhoeus/adapters/faraday'
require 'pararest/request/base'

module Pararest
  class Client
    class Configuration
      include Singleton

      attr_accessor :timeout, :open_timeout

      @@defaults = {
        timeout: 4,
        open_timeout: 2,
      }

      def self.defaults
        @@defaults
      end

      def initialize
        @@defaults.each_pair{|k,v| self.send("#{k}=",v)}
      end
    end

    def self.config
      Configuration.instance
    end

    def self.configure
      yield config
    end

    attr_reader :requests, :options

    def initialize(options = {})
      @requests = []
      @options = {
        timeout: Client.config.timeout,
        open_timeout: Client.config.open_timeout,
        }.merge(options)
      @connection = Faraday.new do |builder|
        builder.use Faraday::Adapter::Typhoeus
 #       builder.response :logger
      end
      @connection.options.merge(@options)
    end

    def add_get(url)
      add Request::Base.new(url)
    end

    def add(request)
      @requests << request
      request
    end

    def send
      @connection.in_parallel do
        @requests.each {|request|
          request.response = @connection.get request.url, request.params
        }
      end
    end
  end
end
