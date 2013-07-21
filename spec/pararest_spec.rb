require "spec_helper"
require "pararest/client"

module Pararest
  describe Client do
    context 'クライアント作成直後' do
      describe 'Client#size' do
        subject { Client.new }
        it { expect(subject.size).to eq 0 }
      end
    end
  end
end
