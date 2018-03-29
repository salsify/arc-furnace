require 'spec_helper'

describe ArcFurnace::PassthroughSink do
  let(:sink) { ArcFurnace::PassthroughSink.new }

  describe '#row' do
    it 'works' do
      expect(sink.row("this")).to eq "this"
      expect(sink.row({ this: "this" })).to eq({ this: "this" })
    end
  end

end
