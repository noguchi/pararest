require 'rexml/document'

module Pararest
  module Request
    class YahooAuctions < Base
      class Configuration
        include Singleton

        attr_accessor :base_url, :yahoo_japan_appid
        @@defaults = {
          base_url: 'https://auctions.yahooapis.jp/AuctionWebService/V2/',
          yahoo_japan_appid: nil
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
        camera: 23_636,
        lens: 23_684,
        software: 23_568,
        all: 0
      }.freeze

      def self.search(keyword, category_id = :all)
        if CATEGORY_ALIAS.key?(category_id)
          category_id = CATEGORY_ALIAS[category_id]
        end
        YahooAuctions.new("#{YahooAuctions.config.base_url}search", appid: YahooAuctions.config.yahoo_japan_appid,
                                                                    type: 'all',
                                                                    sort: 'bids',
                                                                    query: keyword,
                                                                    category: category_id,
                                                                    output: 'xml')
      end

      def self.detail(auction_id)
        YahooAuctions.new("#{YahooAuctions.config.base_url}auctionItem", appid: YahooAuctions.config.yahoo_japan_appid,
                                                                         auctionID: auction_id,
                                                                         output: 'xml')
      end

      def response_filter(response)
        begin
          response.env[:body] = MultiXml.parse(response.env[:body])
        rescue
          response.env[:body] = nil
        end
        response
      end

      def referer_url(url)
        url
      end

      def beacon_url
        nil
      end

      def items
        a = []
        return a unless response && response.body && response.body['ResultSet'] && response.body['ResultSet']['Result'] && response.body['ResultSet']['Result']['Item']
        response.body['ResultSet']['Result']['Item'].each do |item|
          begin
            m = Hashie::Mash.new
            m.auction_id = item['AuctionID']
            m.title = item['Title']
            m.url = referer_url(ssl(item['AuctionItemUrl']))
            m.price = item['CurrentPrice'].to_i
            m.image_url = ssl(item['Image']['__content__'])
            m.image_width = item['Image']['width']
            m.image_height = item['Image']['height']
            m.beacon_url = beacon_url
            m.bids = item['Bids']
            m.end_time = Time.parse(item['EndTime'])
            a << m
          rescue => e
            p e
          end
        end
        a
      end
    end
  end
end
