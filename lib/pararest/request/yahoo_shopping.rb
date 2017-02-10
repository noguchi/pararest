module Pararest
  module Request
    class YahooShopping < Base
      class Configuration
        include Singleton

        attr_accessor :base_url, :yahoo_japan_appid, :valuecommerce_pid, :valuecommerce_sid
        @@defaults = {
          base_url: 'https://shopping.yahooapis.jp/ShoppingWebService/V1/json/',
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
                                                                        callback: 'loaded',
                                                                        query: keyword,
                                                                        type: 'all',
                                                                        category_id: category_id,
                                                                        image_size: '600')
      end

      def response_filter(response)
        begin
          response.env[:body] = MultiJson.load(response.env[:body].gsub!(/loaded\((.*)\);?$/m, '\\1'))
        rescue
          response.env[:body] = nil
        end
        response
      end

      def beacon_url
        if YahooShopping.config.valuecommerce_sid && YahooShopping.config.valuecommerce_pid
          "https://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=#{YahooShopping.config.valuecommerce_sid}&pid=#{YahooShopping.config.valuecommerce_pid}"
        end
      end

      def items
        a = []
        return a unless response && response.body && response.body['ResultSet'] && response.body['ResultSet']['0'] && response.body['ResultSet']['0']['Result']
        response.body['ResultSet']['0']['Result'].each do |_key, item|
          begin
            m = Hashie::Mash.new
            m.title = item['Name']
            m.url = ssl(item['Url'])
            m.price = item['Price']['_value'].to_i
            if item['ExImage']
              m.image_url = ssl(item['ExImage']['Url'])
              m.image_width = item['ExImage']['Width']
              m.image_height = item['ExImage']['Height']
            else
              m.image_url = ssl(item['Image']['Medium'])
              m.image_width = '146'
              m.image_height = '146'
            end
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
