module Pararest
  module Request
    class YahooAuctions < Base
      class Configuration
        include Singleton

        attr_accessor :base_url, :yahoo_japan_appid, :valuecommerce_pid, :valuecommerce_sid
        @@defaults = {
          base_url: 'http://auctions.yahooapis.jp/AuctionWebService/V2/',
          yahoo_japan_appid: nil,
          valuecommerce_sid: nil,
          valuecommerce_pid: nil,
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

      CATEGORY_ALIAS = {
        camera: 23636,
        lens: 23684,
        software: 23568,
        all: 0,
      }

      def self.search(keyword, category_id = :all)
        if CATEGORY_ALIAS.has_key?(category_id)
          category_id = CATEGORY_ALIAS[category_id]
        end
        YahooAuctions.new("#{YahooAuctions.config.base_url}search", {
          appid: YahooAuctions.config.yahoo_japan_appid,
          type: 'all',
          sort: 'bids',
          query: keyword,
          category: category_id,
          callback: 'loaded',
          output: 'json',
        })
      end

      def response_filter(response)
        begin
          response.env[:body] = MultiJson.load(response.env[:body].gsub! /^loaded\((.*)\);?$/m, '\\1')
        rescue
          response.env[:body] = nil
        end
        response
      end

      def referer_url(url)
        if YahooAuctions.config.valuecommerce_sid && YahooAuctions.config.valuecommerce_pid
          "http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=#{YahooAuctions.config.valuecommerce_sid}&pid=#{YahooAuctions.config.valuecommerce_pid}&vc_url=#{CGI::escape(url)}"
        else
          url
        end
      end

      def beacon_url
        if YahooAuctions.config.valuecommerce_sid && YahooAuctions.config.valuecommerce_pid
          "http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=#{YahooAuctions.config.valuecommerce_sid}&pid=#{YahooAuctions.config.valuecommerce_pid}"
        else
          nil
        end
      end

      def items
        a = []
        return a unless (response && response.body && response.body['ResultSet'] && response.body['ResultSet']['Result'] && response.body['ResultSet']['Result']['Item'])
        response.body['ResultSet']['Result']['Item'].each {|item|
          begin
            m = Hashie::Mash.new
            m.title = item['Title']
            m.url = referer_url(item['AuctionItemUrl'])
            m.price = item['CurrentPrice'].to_i
            m.image_url = item['Image']
            m.beacon_url = beacon_url
            m.bids = item['Bids']
            m.end_time = Time.parse(item['EndTime'])
            a << m
          rescue
          end
        }
        a
      end
    end
  end
end
