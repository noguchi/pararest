require 'spec_helper'
require 'pararest'

module Pararest
  describe Request::Base do
    context 'www.google.comへのRequest作成後' do
      subject { Request::Base.new('http://www.google.com/') }

      describe 'Request::Base#url' do
        it { expect(subject.url).to eq 'http://www.google.com/' }
      end

      describe 'Request::Base#response' do
        it { expect(subject.params).to be_empty }
      end
    end
  end
end
