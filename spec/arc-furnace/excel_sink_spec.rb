require 'spec_helper'

describe ArcFurnace::ExcelSink do
  let(:target_filename) { Dir::Tmpname.create('output.xlsx') {} }
  let(:expected_output_path) { "#{ArcFurnace.test_root}/resources/excel_source1.xlsx" }
  let(:sink) { ArcFurnace::ExcelSink.new(filename: target_filename, fields: ['id', 'Field 1', 'Field 2']) }
  after { File.delete(target_filename) if File.exists?(target_filename) }

  before do
    sink.row({ 'id' => '111', 'Field 1' => 'boo bar', 'Field 2' => 'baz, bar' })
    sink.row({ 'id' => '222', 'Field 1' => 'baz', 'Field 2' => 'boo bar' })
    sink.finalize
  end

  describe '#row' do
    it 'writes all rows' do
      target_data = Roo::Spreadsheet.open(target_filename, extension: :xlsx).to_a
      expected_data = Roo::Spreadsheet.open(expected_output_path, extension: :xlsx).to_a
      expect(target_data == expected_data).to eq true
    end
  end

end
