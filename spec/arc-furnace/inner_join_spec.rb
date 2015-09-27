require 'spec_helper'

describe ArcFurnace::InnerJoin do
  let(:subsource1) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source1.csv") }
  let(:subsource2) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source2.csv") }
  let(:empty_source) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/empty_source.csv")}
  let(:hash) { ArcFurnace::Hash.new(source: subsource1, key_column: "id") }
  let(:source) { ArcFurnace::InnerJoin.new(source: subsource2, hash: hash) }
  let(:error_handler) { instance_spy("ErrorHandler", missing_primary_key: nil, missing_join_key: nil, duplicate_primary_key: nil, missing_hash_key: nil) }

  before do
    hash.node_id = :hash
    subsource1.node_id = :subsource1
    subsource2.node_id = :subsource2
    empty_source.node_id = :empty_source
    source.node_id = :source

    hash.error_handler = error_handler
    subsource1.error_handler = error_handler
    subsource2.error_handler = error_handler
    empty_source.error_handler = error_handler
    source.error_handler = error_handler

    hash.prepare
    source.prepare
  end

  describe '#row' do
    it 'feeds all rows' do
      expect(source.row.to_hash).to eq ({ "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar", "Field 3" => "boo bar", "Field 4" => "baz, bar" })
      expect(source.row.to_hash).to eq ({ "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar", "Field 3" => "baz", "Field 4" => "boo bar" })
      expect(source.row).to be_nil
    end

    context 'with empty source hash' do
      let(:hash) { ArcFurnace::Hash.new(source: empty_source, key_column: "id" ) }
      let(:source) { ArcFurnace::InnerJoin.new(source: subsource2, hash: hash) }

      it 'returns original source' do
        expect(source.row).to eq nil
      end

      it 'registered missing hash keys' do
        expect(error_handler).not_to have_received(:missing_primary_key)
        expect(error_handler).to have_received(:missing_hash_key).with(key_included_in(['111', '222', '333'])).exactly(3).times
        expect(error_handler).not_to have_received(:duplicate_primary_key)
        expect(error_handler).not_to have_received(:missing_join_key)
      end
    end

    context 'with key_column option' do
      let(:subsource2) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source4.csv") }
      let(:source) { ArcFurnace::InnerJoin.new(source: subsource2, hash: hash, key_column: 'InternalId') }

      it 'feeds all rows' do
        expect(source.row.to_hash).to eq ({ "id" => "111", "InternalId" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar", "Field 3" => "boo bar", "Field 4" => "baz, bar" })
        expect(source.row.to_hash).to eq ({ "id" => "222", "InternalId" => "222", "Field 1" => "baz", "Field 2" => "boo bar", "Field 3" => "baz", "Field 4" => "boo bar" })
        expect(source.row).to be_nil
        expect(error_handler).to have_received(:missing_hash_key).with(key: '333', node_id: :source, source_row: { "InternalId" => "333", "Field 3" => "black", "Field 4" => "brown" })
      end

    end
  end

  describe '#value' do
    it 'feeds all rows' do
      expect(source.value.to_hash).to eq ({ "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar", "Field 3" => "boo bar", "Field 4" => "baz, bar" })
      second_row = { "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar", "Field 3" => "baz", "Field 4" => "boo bar" }
      source.advance
      expect(source.value.to_hash).to eq second_row
      expect(source.value.to_hash).to eq second_row
      expect(source.row.to_hash).to eq second_row
      expect(source.row).to be_nil
    end

  end

end
