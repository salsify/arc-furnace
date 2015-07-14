require 'spec_helper'

describe ArcFurnace::CSVSource do
  let(:source) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source1.csv") }
  describe '#row' do
    it 'feeds all rows' do
      expect(source.row).to eq ({ "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" })
      expect(source.row).to eq ({ "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar" })
      expect(source.row).to be_nil
    end
  end

  describe '#value' do
    it 'feeds all rows' do
      expect(source.value).to eq ({ "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" })
      second_row = { "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar" }
      source.advance
      expect(source.value).to eq second_row
      expect(source.value).to eq second_row
      expect(source.row).to eq second_row
      expect(source.row).to be_nil
    end
  end

  describe 'with duplicates' do
    let(:source) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source3.csv") }
    it 'merges columns' do
      expect(source.row).to eq ({ "id" => "444", "Field 3" => [ "boo bar", "baz" ] })
    end
  end
end
