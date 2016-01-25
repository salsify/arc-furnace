require 'spec_helper'
require 'arc-furnace/multi_excel_source'

describe ArcFurnace::MultiExcelSource do
  let(:source) { ArcFurnace::MultiExcelSource.new(sheets_info_array: sheets_info_array) }
  let(:sheets_info_array) do
    [
      { filename: "#{ArcFurnace.test_root}/resources/excel.xlsx", sheet: sheet_name },
      { filename: "#{ArcFurnace.test_root}/resources/other_excel.xlsx", sheet: sheet_name }
    ]
  end

  let(:sheet_name) { 'Sheet1' }

  let(:row1) { { 'Id' => '1', 'ColA' => 'foo', 'ColB' => 'bar' } }
  let(:row2) { { 'Id' => '2', 'ColA' => 'baz', 'ColC' => 'biz' } }
  let(:row3) { { 'Id' => '3', 'ColA' => 'boo', 'ColB' => 'boop' } }
  let(:row4) { { 'Id' => '4', 'ColA' => 'beez', 'ColC' => 'kneez' } }

  describe '#row and #value' do
    it 'feeds all rows' do
      expect(source.value).to eq row1
      expect(source.row).to eq row1
      expect(source.value).to eq row2
      expect(source.row).to eq row2
      expect(source.value).to eq row3
      expect(source.row).to eq row3
      expect(source.value).to eq row4
      expect(source.row).to eq row4
      expect(source.value).to be_nil
    end
  end

  context 'with Sheet2' do
    let(:sheet_name) { 'Sheet2' }

    let(:row1) { { 'Id' => '1', 'Col1' => 'foo', 'Col2' => 'bar' } }
    let(:row2) { { 'Id' => '2', 'Col1' => 'baz', 'Col3' => 'biz' } }
    let(:row3) { { 'Id' => '3', 'Col1' => 'boo', 'Col2' => 'far' } }
    # RIP BEEZIN
    let(:row4) { { 'Id' => '4', 'Col1' => 'beez', 'Col3' => 'in' } }

    it 'feeds all rows' do
      expect(source.value).to eq row1
      expect(source.row).to eq row1
      expect(source.value).to eq row2
      expect(source.row).to eq row2
      expect(source.value).to eq row3
      expect(source.row).to eq row3
      expect(source.value).to eq row4
      expect(source.row).to eq row4
      expect(source.value).to be_nil
    end
  end
end