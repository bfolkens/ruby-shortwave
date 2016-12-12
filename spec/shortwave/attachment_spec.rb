require 'spec_helper'

describe Shortwave::Attachment do
  before do
    Shortwave::Config.asset_host = 'localhost'
    Shortwave::Config.cache_unsaved_attachments = false
  end

  context 'when cached' do
    let(:obj) { double('obj', test_filename: 'test.jpg', new_record?: true, id: nil) }
    let(:attachment) { Shortwave::Attachment.new(obj, ['test_object', 'test'], nil) }
    before { attachment.cache_unsaved_attachments = true }

    it { expect(attachment.cache_key).to_not be_nil }
    it { expect(attachment.url).to eq("localhost/test_object/test/#{attachment.cache_key}/test.jpg") }
  end

  context 'when stored' do
    let(:obj) { double('obj', test_filename: 'test.jpg', new_record?: false, id: 1001) }
    let(:attachment) { Shortwave::Attachment.new(obj, ['test_object', 'test'], nil) }

    it { expect(attachment.cache_key).to_not be_nil }
    it { expect(attachment.url).to eq('localhost/test_object/test/1001/test.jpg') }
  end

  context 'when filename is empty' do
    let(:obj) { double('obj', test_filename: '', new_record?: true, id: nil) }
    let(:attachment) { Shortwave::Attachment.new(obj, ['test'], nil) }

    it { expect { attachment.path }.to raise_error Shortwave::EmptyFilenameException }
  end

  context 'when a stream is supplied' do
    let(:stream) { StringIO.new('contents') }
    let(:obj) { double('obj', test_filename: 'test.jpg', new_record?: true, id: nil) }
    let(:attachment) { Shortwave::Attachment.new(obj, ['test'], stream) }
    let(:backend) { double }
    before { attachment.backend = backend }

    it 'persists the stream' do
      expect(backend).to receive(:write).with(stream)
      attachment.persist!
    end

    it 'reads the stream' do
      expect(backend).to receive(:read)
      attachment.read
    end

    it 'removes the persisted stream' do
      expect(backend).to receive(:delete!)
      attachment.remove!
    end
  end
end
