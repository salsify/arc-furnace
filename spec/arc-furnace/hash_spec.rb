require 'spec_helper'
require_relative 'test_source'

describe ArcFurnace::Hash do
  let(:row1) { { "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" } }
  let(:row2) { { "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar" } }

  let(:source) { TestSource.new([row1, row2]) }
  let(:hash) { ArcFurnace::Hash.new(source: source, key_column: "id") }

  before { hash.prepare }

  describe '#get' do
    it 'gets rows as expected' do
      expect(hash.get("111")).to eq row1
    end

    context 'with duplicate rows' do
      let(:row3) { { "id" => "222", "Field 1" => "baz" }}
      let(:source) { TestSource.new([row1, row2, row3]) }

      it 'gets last row of key' do
        expect(hash.get("222")).to eq row3
      end
    end
  end

end
