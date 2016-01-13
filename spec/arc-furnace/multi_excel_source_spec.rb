require 'spec_helper'
require 'arc-furnace/multi_excel_source'

describe ArcFurnace::MultiExcelSource do
  let(:sheet) { nil }
  let(:filenames) do
    [
        "#{ArcFurnace.test_root}/resources/excel.csv",
        "#{ArcFurnace.test_root}/resources/other_excel.csv"
    ]
  end

  let(:source) { ArcFurnace::MultiExcelSource.new(filenames: filenames, sheet: sheet) }
  let(:row1) { { 'Id' => '1', 'ColA' => 'foo', 'ColB' => 'bar' } }
  let(:row2) { { 'Id' => '2', 'ColA' => 'baz', 'ColC' => 'biz'} }

  describe '#row and #value' do
    it 'feeds all rows' do
      expect(source.value).to eq row1
      expect(source.row).to eq row1
      expect(source.value).to eq row2
      expect(source.row).to eq row2
      expect(source.value).to be_nil
    end
  end

  context 'with a sheet' do
    let(:sheet) { 'Sheet2' }
    let(:row1) { { 'Id' => '1', 'Col1' => 'foo', 'Col2' => 'bar' } }
    let(:row2) { { 'Id' => '2', 'Col1' => 'baz', 'Col3' => 'biz'} }

    it 'feeds all rows' do
      expect(source.value).to eq row1
      expect(source.row).to eq row1
      expect(source.value).to eq row2
      expect(source.row).to eq row2
      expect(source.value).to be_nil
    end
  end
end