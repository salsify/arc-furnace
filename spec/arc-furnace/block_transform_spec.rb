require 'spec_helper'

describe ArcFurnace::BlockTransform do
  let(:subsource) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source1.csv") }
  let(:source) do
    ArcFurnace::BlockTransform.new(
      source: subsource,
      block: ->(row) do
        row["id"] = row["id"] + "t"
        row
      end
    )
  end
  before do
    source.prepare
  end

  describe '#row' do
    it 'feeds all rows' do
      expect(source.row.to_hash).to eq ({ "id" => "111t", "Field 1" => "boo bar", "Field 2" => "baz, bar" })
      expect(source.row.to_hash).to eq ({ "id" => "222t", "Field 1" => "baz", "Field 2" => "boo bar" })
      expect(source.row).to be_nil
    end
  end

  describe '#value' do
    it 'feeds all rows' do
      expect(source.value.to_hash).to eq ({ "id" => "111t", "Field 1" => "boo bar", "Field 2" => "baz, bar" })
      second_row = { "id" => "222t", "Field 1" => "baz", "Field 2" => "boo bar" }
      source.advance
      expect(source.value.to_hash).to eq second_row
      expect(source.value.to_hash).to eq second_row
      expect(source.row.to_hash).to eq second_row
      expect(source.row).to be_nil
    end
  end
end
