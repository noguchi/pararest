module Pararest
  class Request
    attr_reader :url, :params
    attr_accessor :response

    def initialize(url, params = {})
      @url = url
      @params = params
      @response = nil
    end
  end
end
