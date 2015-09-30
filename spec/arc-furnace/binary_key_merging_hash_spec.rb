require 'spec_helper'
require_relative 'test_source'

describe ArcFurnace::BinaryKeyMergingHash do

  let(:row1) { { "id" => "111", "Field" => "Field1", "Value" => "boo" }.deep_freeze }
  let(:row2) { { "id" => "222", "Field" => "Field1", "Value" => "boo bar" }.deep_freeze }

  let(:source) { TestSource.new([row1, row2]) }
  let(:hash) { ArcFurnace::BinaryKeyMergingHash.new(source: source, primary_key: "id", secondary_key: "Field", value_key: "Value") }
  let(:error_handler) { instance_double("ErrorHandler", missing_primary_key: nil, missing_join_key: nil, duplicate_primary_key: nil) }

  before do
    hash.node_id = :hash
    hash.error_handler = error_handler
    hash.prepare
  end

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

      it 'registered no errors' do
        expect(error_handler).not_to have_received(:missing_primary_key)
        expect(error_handler).not_to have_received(:duplicate_primary_key)
      end
    end

    context 'with nil row values' do
      let(:row3) { {"id" => "111", "Field" => "foo", "Value" => nil }.deep_freeze }
      let(:source) { TestSource.new([row1, row2, row3])}

      it 'drops all nil vlaues' do
        expect(hash.get("111")).to eq ({ "Field1" => ["boo"]})
      end

      it 'registered a missing key' do
        # Nil values are considered missing primary keys
        expect(error_handler).to have_received(:missing_primary_key).with(source_row: row3, node_id: :hash)
        expect(error_handler).not_to have_received(:duplicate_primary_key)
      end
    end
  end

  describe 'error handling' do
    let(:row3) { { "Field" => "foo", "Value" => nil }.deep_freeze }
    let(:source) { TestSource.new([row1, row2, row3])}

    it 'registered a missing key' do
      expect(error_handler).to have_received(:missing_primary_key).with(source_row: row3, node_id: :hash)
      expect(error_handler).not_to have_received(:duplicate_primary_key)
    end
  end

end
