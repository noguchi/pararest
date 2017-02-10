module Pararest
  module Request
    class Base
      attr_reader :url, :path, :params

      def initialize(url, params = {})
        @url = url
        @params = params
        @response = nil
        @filtered = false
      end

      attr_writer :response

      def response
        unless @filtered
          @response = response_filter(@response)
          @filtered = true
        end
        @response
      end

      def response_filter(response)
        response
      end

      def ssl(url)
        url.gsub('http:', 'https:')
      end
    end
  end
end
