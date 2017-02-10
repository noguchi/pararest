module Pararest
  module Request
    # 楽天APIリクエストクラス
    class Rakuten < Base
      class Configuration
        include Singleton

        attr_accessor :base_url, :version, :application_id, :affiliate_id
        @@defaults = {
          base_url: 'https://app.rakuten.co.jp/services/api/IchibaItem/',
          version: '20140222',
          application_id: nil,
          affiliate_id: nil
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
        camera: 100_083,
        lens: 110_335,
        software: 100_103,
        all: 0
      }.freeze

      def self.search(keyword, category_id = :all)
        if CATEGORY_ALIAS.key?(category_id)
          category_id = CATEGORY_ALIAS[category_id]
        end
        Rakuten.new("#{Rakuten.config.base_url}Search/#{Rakuten.config.version}", 'applicationId' => Rakuten.config.application_id,
                                                                                  'affiliateId' => Rakuten.config.affiliate_id,
                                                                                  'keyword' => keyword,
                                                                                  'genreId' => category_id,
                                                                                  'sort' => 'standard',
                                                                                  'callback' => 'loaded')
      end

      def response_filter(response)
        response.env[:body] = MultiJson.load(response.env[:body].gsub!(/^loaded\((.*)\);?$/m, '\\1'))
        response
      end

      def items
        a = []
        return a unless response && response.body && response.body['Items']
        response.body['Items'].each do |e|
          begin
            item = e['Item']
            m = Hashie::Mash.new
            m.title = item['itemName']
            m.url = ssl(item['itemUrl'])
            m.price = item['itemPrice'].to_i
            m.image_url = ssl(item['mediumImageUrls'].first['imageUrl'])
            m.image_width = '128'
            m.image_height = '128'
            m.beacon_url = nil
            a << m
          rescue
          end
        end
        a
      end
    end
  end
end
