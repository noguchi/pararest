require 'forwardable'

module Pararest
  class Client
    extend Forwardable

    def size
      0
    end

    def initialize
      @requests = []
    end
  end
end
