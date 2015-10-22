require 'spec_helper'
require_relative 'test_source'

describe ArcFurnace::BlockFilter do
  let(:row1) { { "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" } }
  let(:row2) { { "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar" } }

  let(:source) { TestSource.new([row1, row2]) }
  let(:filter_param) { 'filter' }
  let(:filter) do
    ArcFurnace::BlockFilter.new(source: source, filter_param: filter_param, block: -> (row) { row['id'] != '222' })
  end

  before do
    filter.prepare
  end

  describe '#row' do
    it 'feeds all rows' do
      expect(filter.row).to eq row1
      expect(filter.row).to be_nil
    end
  end

  describe '#value' do
    it 'feeds all rows' do
      expect(filter.value).to eq row1
      expect(filter.value).to eq row1
      expect(filter.row).to eq row1
      expect(filter.value).to be_nil
      expect(filter).to be_empty
    end
  end

end
