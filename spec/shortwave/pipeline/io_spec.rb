require 'spec_helper'

describe Shortwave::Pipeline::IO do
  context 'when an io is supplied' do
    let(:obj) do
      io = StringIO.new('chunk')
      Shortwave::Pipeline::IO.new(io)
    end

    it { expect(obj.read).to eql('chunk') }

    it 'reads sequentially' do
      expect(obj.read(3)).to eql('chu')
      expect(obj.read(2)).to eql('nk')
    end
  end
end
