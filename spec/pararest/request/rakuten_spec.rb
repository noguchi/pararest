require "spec_helper"
require "pararest/request/rakuten"

module Pararest
  describe Request::Rakuten do
    Request::Rakuten.configure do |c|
      c.application_id = "bcb94d46f956a4dc09f29b9557b592f9"
      c.affiliate_id = ""
    end

    context '楽天APIへの検索リクエスト作成' do
      subject { Request::Rakuten.search('nikon d800', '100083') }

      describe 'Rakuten#url' do
        it { expect(subject.url).to eq "https://app.rakuten.co.jp/services/api/IchibaItem/Search/20130424" }
      end

      describe 'Rakuten#params' do
        it { expect(subject.params).to include(
          "applicationId" => "bcb94d46f956a4dc09f29b9557b592f9",
          "genreId" => "100083",
          "keyword" => "nikon d800",
        ) }
      end
    end

    context '楽天APIにリクエストを送り、レスポンスを受け取る' do
      before do
        VCR.use_cassette 'rakuten' do
          c = Pararest::Client.new
          @request = c.add(Request::Rakuten.search('nikon d800', '100083'))
          c.send
        end
      end
      
      describe 'Rakuten#response' do
        subject { @request.response }
        it 'statusが200 OK' do
          expect(subject.env[:status]).to eq 200
        end
        it 'bodyがMultiJsonでparseしたHashのインスタンス' do
          expect(subject.body).to be_an_instance_of(Hash)
        end
      end

      describe 'Rakuten#items' do
        subject { @request.items }
        it 'items.size = 30' do
          expect(subject.size).to eq 30
        end
      end
    end
  end
end