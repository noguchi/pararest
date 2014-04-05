require "spec_helper"
require "pararest"

module Pararest
  describe Request::YahooAuctions do
    Request::YahooAuctions.configure do |c|
      c.yahoo_japan_appid = "testappid"
      c.valuecommerce_sid = "12345"
      c.valuecommerce_pid = "67890"
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

    context 'ヤフオクAPIに検索リクエストを送り、レスポンスを受け取る' do
      before do
        VCR.use_cassette 'yahoo_auctions' do
          c = Pararest::Client.new
          @request = c.add(Request::YahooAuctions.search('nikon d800', '2084261634'))
          c.send
        end
      end
      describe 'YahooAuctions#response' do
        subject { @request.response }
        it 'statusが200 OK' do
          expect(subject.env[:status]).to eq 200
        end
        it 'bodyがMultiXmlでparseしたHashのインスタンス' do
          expect(subject.body).to be_an_instance_of(Hash)
        end
      end

      describe 'YahooAuctions#response.body' do
        subject { @request.response.body }
        it 'Itemの個数が20' do
          expect(subject['ResultSet']['Result']['Item'].size).to eq 20
        end
      end

      describe 'YahooAuctions#items' do
        subject { @request.items }
        it 'items.size = 20' do
          expect(subject.size).to eq 20
        end
      end
    end

    context 'ヤフオクAPIへの商品詳細リクエスト作成' do
      subject { Request::YahooAuctions.detail('x338641869') }

      describe 'YahooAuctions#url' do
        it { expect(subject.url).to eq "http://auctions.yahooapis.jp/AuctionWebService/V2/auctionItem" }
      end

      describe 'YahooAuctions#params' do
        it { expect(subject.params).to include(appid: "testappid", auctionID: "x338641869") }
      end
    end

    context 'ヤフオクAPIに商品詳細リクエストを送り、レスポンスを受け取る' do
      before do
        VCR.use_cassette 'yahoo_auctions_detail' do
          c = Pararest::Client.new
          @request = c.add(Request::YahooAuctions.detail('x338641869'))
          c.send
        end
      end
      describe 'YahooAuctions#response' do
        subject { @request.response }
        it 'statusが200 OK' do
          expect(subject.env[:status]).to eq 200
        end
        it 'bodyがMultiXmlでparseしたHashのインスタンス' do
          expect(subject.body).to be_an_instance_of(Hash)
        end
      end

      describe 'YahooAuctions#response.body' do
        subject { @request.response.body }
        it '画像の情報が取得できる' do
          expect(subject['ResultSet']['Result']['Img']['Image1'].keys).to include("__content__", "width", "height", "alt")
        end
      end
    end
  end
end
