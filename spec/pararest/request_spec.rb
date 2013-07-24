require "spec_helper"
require "pararest/request"

module Pararest
  describe Request do
    context 'www.google.comへのRequest作成後' do
      subject { Request.new("http://www.google.com/") }

      describe 'Request#url' do
        it { expect(subject.url).to eq "http://www.google.com/" }
      end

      describe 'Request#response' do
        it { expect(subject.params).to be_empty }
      end
    end
  end
end
