require 'spec_helper'

describe Shortwave::Pipeline::Source do
  context 'when a processor is defined' do
    let(:obj) do
      chunk = 'chunk'

      Shortwave::Pipeline::Source.new.tap do |obj|
        obj.define_singleton_method(:process) do
          if @first_byte
            @first_byte = false
            Fiber.yield(chunk.size)
          end

          @iobuffer << chunk
          Fiber.yield
        end
        obj.send(:reset)
      end
    end

    it { expect(obj.read).to eql('chunk') }
    it { expect(obj.read(4)).to eql('chun') }

    it 'reads by replacing buffer content' do
      buffer = ''
      obj.read(4, buffer)
      expect(buffer).to eql('chun')
    end

    it 'reads sequentially' do
      expect(obj.read(3)).to eql('chu')
      expect(obj.read(2)).to eql('nk')
    end

    it 'invokes callback after chunk read' do
      obj.chunk_read_delegate = double
      expect(obj.chunk_read_delegate).to receive(:call).with(kind_of(StringIO), 'chunk')

      obj.read
    end

    it 'rewinds and reads from memo' do
      obj.read(3)
      obj.rewind

      expect(obj.read(3)).to eql('chu')
      expect(obj.read(2)).to eql('nk')
    end
  end
end
