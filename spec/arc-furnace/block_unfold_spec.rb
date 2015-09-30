require 'spec_helper'
require_relative 'test_source'

describe ArcFurnace::BlockUnfold do
  let(:row1) { { "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" } }
  let(:row2) { { "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar" } }

  let(:source) { TestSource.new([row1, row2]) }
  let(:unfold) do
    ArcFurnace::BlockUnfold.new(source: source, block: -> (row) { [row.deep_dup, row.deep_dup] })
  end

  before do
    unfold.prepare
  end

  describe '#row' do
    it 'feeds all rows' do
      expect(unfold.row).to eq row1
      expect(unfold.row).to eq row1
      expect(unfold.row).to eq row2
      expect(unfold.row).to eq row2
      expect(unfold.row).to be_nil
    end
  end

  describe '#value' do
    it 'feeds all rows' do
      expect(unfold.value).to eq row1
      unfold.advance
      expect(unfold.value).to eq row1
      expect(unfold.value).to eq row1
      expect(unfold.row).to eq row1
      expect(unfold.value).to eq row2
      expect(unfold.row).to eq row2
      expect(unfold.value).to eq row2
      expect(unfold.row).to eq row2
      expect(unfold).to be_empty
    end
  end

end
