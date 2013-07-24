require 'faraday'
require 'faraday_middleware'
require 'pararest/request'

module Pararest
  class Client
    attr_reader :requests, :options

    def initialize(options = {})
      @requests = []
      @options = {
        timeout: 4,
        open_timeout: 2,
        }.merge(options)
      @connection = Faraday.new do |builder|
        builder.use Faraday::Adapter::EMHttp
        builder.response :xml, content_type: /\bxml$/
#        builder.response :logger
      end
      @connection.options.merge(@options)
    end

    def add_get(url)
      add Request.new(url)
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
