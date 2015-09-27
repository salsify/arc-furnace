require 'spec_helper'
require_relative 'test_source'

describe ArcFurnace::Hash do
  let(:row1) { { "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" } }
  let(:row2) { { "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar" } }

  let(:source) { TestSource.new([row1, row2]) }
  let(:hash) { ArcFurnace::Hash.new(source: source, key_column: "id") }
  let(:error_handler) { instance_spy("ErrorHandler", missing_primary_key: nil, missing_join_key: nil, duplicate_primary_key: nil, missing_hash_key: nil) }

  before do
    hash.node_id = :hash
    source.node_id = :source
    hash.error_handler = error_handler
    source.error_handler = error_handler

    hash.prepare
  end

  describe '#get' do
    it 'gets rows as expected' do
      expect(hash.get("111")).to eq row1
    end

    it_behaves_like 'node operation registered no errors'

    context 'with duplicate rows' do
      let(:row3) { { "id" => "222", "Field 1" => "baz" }}
      let(:source) { TestSource.new([row1, row2, row3]) }

      it 'gets last row of key' do
        expect(hash.get("222")).to eq row3
      end

      it 'registers a duplicate_primary_key' do
        expect(error_handler).to have_received(:duplicate_primary_key).with(duplicate_row: row3, key: '222', node_id: :hash)
      end
    end

    context 'with un-identified row' do
      let(:row3) { { "Field 1" => "baz" }}
      let(:source) { TestSource.new([row1, row2, row3]) }

      it 'registers a missing_primary_key' do
        expect(error_handler).to have_received(:missing_primary_key).with(source_row: row3, node_id: :hash)
      end
    end
  end

  describe "#each" do
    it "yields rows as expected" do
      expect { |b| hash.each(&b) }.to yield_successive_args(["111", row1], ["222", row2])
    end
  end

end
