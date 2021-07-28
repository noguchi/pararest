require 'spec_helper'
require 'pararest'

module Pararest
  describe Request::YahooShopping do
    Request::YahooShopping.configure do |c|
      c.yahoo_japan_appid = 'testappid'
      c.valuecommerce_sid = '12345'
      c.valuecommerce_pid = '67890'
    end

    context 'ヤフーショッピングAPIへの検索リクエスト作成' do
      subject { Request::YahooShopping.search('nikon d780', '47733') }

      describe 'YahooShopping#url' do
        it { expect(subject.url).to eq 'https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch' }
      end

      describe 'YahooShopping#params' do
        it do
          expect(subject.params).to include(
            appid: 'testappid',
            category_id: '47733',
            query: 'nikon d780'
          )
        end
      end
    end

    context 'ヤフーショッピングAPIにリクエストを送り、レスポンスを受け取る' do
      before do
        VCR.use_cassette 'yahoo_shopping' do
          c = Pararest::Client.new
          @request = c.add(Request::YahooShopping.search('nikon d780', '47733'))
          c.send
        end
      end
      describe 'YahooShopping#response' do
        subject { @request.response }
        it 'statusが200 OK' do
          expect(subject.env[:status]).to eq 200
        end
        it 'bodyがMultiJsonでparseしたHashのインスタンス' do
          expect(subject.body).to be_an_instance_of(Hash)
        end
      end

      describe 'YahooShopping#items' do
        subject { @request.items }
        it 'items.size = 20' do
          expect(subject.size).to eq 20
        end
      end
    end
  end
end
