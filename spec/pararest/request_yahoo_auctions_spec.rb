require "spec_helper"
require "pararest/request/yahoo_auctions"

module Pararest
  describe Request::YahooAuctions do
    Request::YahooAuctions.configure do |c|
      c.yahoo_japan_appid = "testappid"
    end

    context 'ヤフオクAPIへの検索リクエスト作成' do
      subject { Request::YahooAuctions.search('nikon d800', '2084261634') }

      describe 'YahooAuctions#url' do
        it { expect(subject.url).to eq "http://auctions.yahooapis.jp/AuctionWebService/V2/search" }
      end

      describe 'YahooAuctions#params' do
        it { expect(subject.params).to include(appid: "testappid", type: "all", sort: "bids", query: "nikon d800", category: "2084261634") }
      end
    end

    context 'ヤフオクAPIにリクエストを送り、レスポンスを受け取る' do
      before do
        c = Client.new
        @request = c.add(Request::YahooAuctions.search('nikon d800', '2084261634'))
        c.send
      end
      describe 'YahooAuctions#response' do
        subject { @request.response }
        it 'statusが200 OK' do
          expect(subject.env[:status]).to eq 200
        end
        it 'bodyがMultiJsonでparseしたHashのインスタンス' do
          expect(subject.body).to be_an_instance_of(Hash)
        end
      end

      describe 'YahooAuctions#response.body' do
        subject { @request.response.body }
        it 'Itemの個数が50' do
          expect(subject['ResultSet']['Result']['Item'].size).to eq 50
        end
      end

      describe 'YahooAuctions#items' do
        subject { @request.items }
        it 'items.size = 50' do
          expect(subject.size).to eq 50
        end
      end
    end
  end
end
