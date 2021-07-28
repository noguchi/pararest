module Pararest
  module Request
    class YahooShopping < Base
      class Configuration
        include Singleton

        attr_accessor :base_url, :yahoo_japan_appid, :valuecommerce_pid, :valuecommerce_sid
        @@defaults = {
          base_url: 'https://shopping.yahooapis.jp/ShoppingWebService/V3/',
          yahoo_japan_appid: nil,
          valuecommerce_sid: nil,
          valuecommerce_pid: nil
        }

        def self.defaults
          @@defaults
        end

        def initialize
          @@defaults.each_pair { |k, v| send("#{k}=", v) }
        end
      end

      def self.config
        Configuration.instance
      end

      def self.configure
        yield config
      end

      CATEGORY_ALIAS = {
        camera: 2443,
        lens: 2465,
        software: 150,
        all: 0
      }.freeze

      def self.search(keyword, category_id = :all)
        if CATEGORY_ALIAS.key?(category_id)
          category_id = CATEGORY_ALIAS[category_id]
        end
        YahooShopping.new("#{YahooShopping.config.base_url}itemSearch", appid: YahooShopping.config.yahoo_japan_appid,
                                                                        affiliate_type: 'vc',
                                                                        affiliate_id: "http%3A%2F%2Fck.jp.ap.valuecommerce.com%2Fservlet%2Freferral%3Fsid%3D#{YahooShopping.config.valuecommerce_sid}%26pid%3D#{YahooShopping.config.valuecommerce_pid}%26vc_url%3D",
                                                                        query: keyword,
                                                                        type: 'all',
                                                                        category_id: category_id,
                                                                        image_size: '600')
      end

      def response_filter(response)
        response.env[:body] = MultiJson.load(response.env[:body])
        response
      end

      def beacon_url
        if YahooShopping.config.valuecommerce_sid && YahooShopping.config.valuecommerce_pid
          "https://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=#{YahooShopping.config.valuecommerce_sid}&pid=#{YahooShopping.config.valuecommerce_pid}"
        end
      end

      def items
        a = []
        return a unless response && response.body && response.body['hits']
        response.body['hits'].each do |item|
          begin
            m = Hashie::Mash.new
            m.title = item['name']
            m.url = ssl(item['url'])
            m.price = item['price']
            m.image_url = ssl(item['exImage']['url'])
            m.image_width = item['exImage']['width']
            m.image_height = item['exImage']['height']
            m.beacon_url = beacon_url
            a << m
          rescue
          end
        end
        a
      end
    end
  end
end
