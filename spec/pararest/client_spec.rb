require 'spec_helper'
require 'pararest'

module Pararest
  describe Client do
    context 'Clientをデフォルト値で作成' do
      subject { Client.new }
      describe 'Client#options' do
        it { expect(subject.options).to include(timeout: 4, open_timeout: 2) }
      end
      describe 'Client#requests' do
        it { expect(subject.requests).to be_empty }
      end
    end

    context 'Clientをtimeout: 10で作成' do
      subject { Client.new(timeout: 10) }
      describe 'Client#options' do
        it { expect(subject.options).to include(timeout: 10) }
      end
    end

    context 'Clientにwww.yahoo.co.jpへのリクエストを追加' do
      subject do
        c = Client.new
        @req = c.add_get('http://www.yahoo.co.jp/')
        c
      end
      describe 'Client#requests.size' do
        it { expect(subject.requests.size).to eq 1 }
      end
      describe 'Client#send' do
        it 'リクエストを送信するとstatus 200 OKが帰る' do
          subject.send
          expect(@req.response.env[:status]).to eq 200
        end
      end
    end

    context 'Clientに存在しないURLのリクエストを追加' do
      before do
        c = Client.new
        req = c.add_get('http://foo.photoxp.jp/')
        c.send
        @response = req.response
      end
      describe 'Client#send' do
        it { expect(@response.status).to eq 0 }
        it { expect(@response.body).to be_empty }
      end
    end

    context 'Clientにgoogle/yahoo/facebookへのリクエストを追加' do
      subject do
        c = Client.new
        @google = c.add_get('http://www.google.co.jp/')
        @yahoo = c.add_get('http://www.yahoo.co.jp/')
        @facebook = c.add_get('https://www.facebook.com/')
        c
      end
      describe 'Client#requests.size' do
        it { expect(subject.requests.size).to eq 3 }
      end
      describe 'Client#send' do
        it 'リクエストを送信するとstatus 200 OKが帰る' do
          subject.send
          expect(@google.response.env[:status]).to eq 200
          expect(@yahoo.response.env[:status]).to eq 200
          expect(@facebook.response.env[:status]).to eq 200
        end
      end
    end
  end
end
