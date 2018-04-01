require 'spec_helper'

describe ArcFurnace::PassthroughSink do
  let(:sink) { ArcFurnace::PassthroughSink.new }

  describe '#row' do
    it 'works with strings' do
      expect(sink.row('this').to_a).to eq ['this']
    end
  end

  describe '#row' do
    it 'works with hashes' do
      expect(sink.row({ this: 'this' }).to_a).to eq([{ this: 'this' }])
    end
  end

end
