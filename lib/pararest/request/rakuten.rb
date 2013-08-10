module Pararest
  module Request
    class Rakuten < Base
      class Configuration
        include Singleton

        attr_accessor :base_url, :version, :application_id, :affiliate_id
        @@defaults = {
          base_url: 'https://app.rakuten.co.jp/services/api/IchibaItem/',
          version: "20130424",
          application_id: nil,
          affiliate_id: nil,
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

      def self.search(keyword, genre_id)
        Rakuten.new("#{Rakuten.config.base_url}Search/#{Rakuten.config.version}", {
          'applicationId' => Rakuten.config.application_id,
          'affiliateId' => Rakuten.config.affiliate_id,
          'keyword' => keyword,
          'genreId' => genre_id,
          'sort' => 'standard',
          'callback' => 'loaded',
        })
      end

      def response_filter(response)
        response.env[:body] = MultiJson.load(response.env[:body].gsub! /^loaded\((.*)\);?$/m, '\\1')
        response
      end

      def items
        a = []
        return a unless (response && response.body['Items'])
        response.body['Items'].each {|e|
          item = e['Item']
          m = Hashie::Mash.new
          m.title = item['itemName']
          m.url = item['itemUrl']
          m.price = item['itemPrice'].to_i
          m.image_url = item['mediumImageUrls'].first['imageUrl']
          m.beacon_url = nil
          a << m
        }
        a
      end
    end
  end
end
