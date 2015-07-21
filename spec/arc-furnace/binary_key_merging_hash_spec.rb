require 'spec_helper'
require_relative 'test_source'

describe ArcFurnace::BinaryKeyMergingHash do

  let(:row1) { { "id" => "111", "Field" => "Field1", "Value" => "boo" }.deep_freeze }
  let(:row2) { { "id" => "222", "Field" => "Field1", "Value" => "boo bar" }.deep_freeze }

  let(:source) { TestSource.new([row1, row2]) }
  let(:hash) { ArcFurnace::BinaryKeyMergingHash.new(source: source, primary_key: "id", secondary_key: "Field", value_key: "Value") }

  before { hash.prepare }

  describe '#get' do
    it 'gets rows as expected' do
      expect(hash.get("111")).to eq ({ "Field1" => ["boo"]})
    end

    context 'with duplicate rows' do
      let(:row3) { { "id" => "111", "Field" => "Field1", "Value" => [ "baz", "biz" ] }.deep_freeze }
      let(:source) { TestSource.new([row1, row2, row3]) }

      it 'gets last row of key' do
        expect(hash.get("111")).to eq ({ "Field1" => [ "boo", "baz", "biz" ]})
      end
    end

    context 'with nil row values' do
      let(:row3) { {"id" => "111", "Field" => "foo", "Value" => nil }.deep_freeze }
      let(:source) { TestSource.new([row1, row2, row3])}

      it 'drops all nil vlaues' do
        expect(hash.get("111")).to eq ({ "Field1" => ["boo"]})
      end
    end
  end

end
