require 'spec_helper'

describe Shortwave::Pipeline::Excon do
  context 'when a url is supplied' do
    let(:obj) do
      Excon.mock = true
      Excon.stub({}, { body: 'chunk', status: 200 })
      
      Shortwave::Pipeline::Excon.new('http://test.com/file.txt')
    end

    it { expect(obj.read).to eql('chunk') }

    it 'reads sequentially' do
      expect(obj.read(3)).to eql('chu')
      expect(obj.read(2)).to eql('nk')
    end
  end
end
