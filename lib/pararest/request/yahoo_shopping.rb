require 'multi_json'
require 'awesome_print'

module Pararest
  module Request
    class YahooShopping < Base
      class Configuration
        include Singleton

        attr_accessor :base_url, :yahoo_japan_appid, :valuecommerce_pid, :valuecommerce_sid
        @@defaults = {
          base_url: 'http://shopping.yahooapis.jp/ShoppingWebService/V1/json/',
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

      def self.search(keyword, category_id)
        YahooShopping.new("#{YahooShopping.config.base_url}itemSearch", {
          appid: YahooShopping.config.yahoo_japan_appid,
          affiliate_type: "vc",
          affiliate_id: "http%3A%2F%2Fck.jp.ap.valuecommerce.com%2Fservlet%2Freferral%3Fsid%3D#{YahooShopping.config.valuecommerce_sid}%26pid%3D#{YahooShopping.config.valuecommerce_pid}%26vc_url%3D",
          callback: 'loaded',
          query: keyword,
          type: 'all',
          category_id: category_id,
        })
      end

      def response_filter(response)
        response.env[:body] = MultiJson.load(response.env[:body].gsub! /^loaded\((.*)\);?$/m, '\\1')
        response
      end

      def beacon_url
        if YahooShopping.config.valuecommerce_sid && YahooShopping.config.valuecommerce_pid
          "http://ad.jp.ap.valuecommerce.com/servlet/gifbanner?sid=#{YahooShopping.config.valuecommerce_sid}&pid=#{YahooShopping.config.valuecommerce_pid}"
        else
          nil
        end
      end

      def items
        a = []
        return a unless (response && response.body['ResultSet'] && response.body['ResultSet']['0'] && response.body['ResultSet']['0']['Result'])
        response.body['ResultSet']['0']['Result'].each {|key, item|
          next unless /^\d+$/ =~ key
          item['BeaconUrl'] = beacon_url
          a << item
        }
        a
      end
    end
  end
end
