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

      def response=(response)
        @response = response
      end

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
    end
  end
end
