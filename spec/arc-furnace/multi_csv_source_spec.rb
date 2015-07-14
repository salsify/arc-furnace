require 'spec_helper'

describe ArcFurnace::MultiCSVSource do
  let(:filenames) do
    [
      "#{ArcFurnace.test_root}/resources/source1.csv",
      "#{ArcFurnace.test_root}/resources/empty_source.csv",
      "#{ArcFurnace.test_root}/resources/source2.csv"
    ]
  end

  let(:source) { ArcFurnace::MultiCSVSource.new(filenames: filenames) }
  let(:rows) do
    [
      { "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" },
      { "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar" },
      { "id" => "111", "Field 3" => "boo bar", "Field 4" => "baz, bar" },
      { "id" => "222", "Field 3" => "baz", "Field 4" => "boo bar" },
      { "id" => "333", "Field 3" => "black", "Field 4" => "brown" }
    ]
  end

  describe '#row' do
    it 'feeds all rows' do
      expect(source.row).to eq rows[0]
      expect(source.row).to eq rows[1]
      expect(source.row).to eq rows[2]
      expect(source.row).to eq rows[3]
      expect(source.row).to eq rows[4]
      expect(source.row).to be_nil
    end
  end

  describe '#value' do
    it 'feeds all rows' do
      expect(source.value).to eq rows[0]
      source.advance
      expect(source.value).to eq rows[1]
      expect(source.value).to eq rows[1]
      expect(source.row).to eq rows[1]
      expect(source.row).to eq rows[2]
      expect(source.value).to eq rows[3]
      expect(source.value).to eq rows[3]
      expect(source.advance).to eq rows[4]
      expect(source.value).to eq rows[4]
      expect(source.empty?).to eq false
      expect(source.row).to eq rows[4]
      expect(source.value).to eq nil
      expect(source.empty?).to eq true
      expect(source.row).to eq nil
    end
  end
end
