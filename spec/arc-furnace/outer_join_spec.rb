require 'spec_helper'

describe ArcFurnace::OuterJoin do
  let(:subsource1) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source1.csv") }
  let(:subsource2) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source2.csv") }
  let(:empty_source) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/empty_source.csv")}
  let(:hash) { ArcFurnace::Hash.new(source: subsource1, key_column: "id") }
  let(:source) { ArcFurnace::OuterJoin.new(source: subsource2, hash: hash) }

  before do
    hash.prepare
    source.prepare
  end

  describe '#row' do
    it 'returns the current row and advances to the next row' do
      expect(source.row).to eq ({ "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar", "Field 3" => "boo bar", "Field 4" => "baz, bar" })
      expect(source.row).to eq ({ "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar", "Field 3" => "baz", "Field 4" => "boo bar" })
      expect(source.row).to eq ({ "id" => "333", "Field 3" => "black", "Field 4" => "brown" })
      expect(source.row).to be_nil
    end

    context 'with empty source hash' do
      let(:hash) { ArcFurnace::Hash.new(source: empty_source, key_column: "id" ) }
      let(:source) { ArcFurnace::OuterJoin.new(source: subsource2, hash: hash) }

      it 'returns original source' do
        expect(source.row).to eq ({ "id" => "111", "Field 3" => "boo bar", "Field 4" => "baz, bar" })
        expect(source.row).to eq ({ "id" => "222", "Field 3" => "baz", "Field 4" => "boo bar" })
        expect(source.row).to eq ({ "id" => "333", "Field 3" => "black", "Field 4" => "brown" })
        expect(source.row).to be_nil
      end
    end

    context 'with key_column option' do
      let(:subsource4) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source4.csv") }
      let(:source) { ArcFurnace::OuterJoin.new(source: subsource4, hash: hash, key_column: 'InternalId') }

      it 'feeds all rows' do
        expect(source.row).to eq ({ "id" => "111", "InternalId" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar", "Field 3" => "boo bar", "Field 4" => "baz, bar" })
        expect(source.row).to eq ({ "id" => "222", "InternalId" => "222", "Field 1" => "baz", "Field 2" => "boo bar", "Field 3" => "baz", "Field 4" => "boo bar" })
        expect(source.row).to eq ({ "InternalId" => "333", "Field 3" => "black", "Field 4" => "brown" })
        expect(source.row).to be_nil
      end
    end
  end

  describe '#value' do
    it 'returns the current row' do
      expect(source.value.to_hash).to eq ({ "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar", "Field 3" => "boo bar", "Field 4" => "baz, bar" })
      second_row = { "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar", "Field 3" => "baz", "Field 4" => "boo bar" }
      third_row = { "id" => "333", "Field 3" => "black", "Field 4" => "brown" }
      source.advance
      expect(source.value.to_hash).to eq second_row
      expect(source.value.to_hash).to eq second_row
      expect(source.row.to_hash).to eq second_row
      expect(source.value.to_hash).to eq third_row
      expect(source.row.to_hash).to eq third_row
      expect(source.row).to be_nil
    end
  end
end
