require 'spec_helper'

describe ArcFurnace::CSVSink do
  let(:target_filename) { Dir::Tmpname.create('output.csv') {} }
  let(:expected_output_path) { "#{ArcFurnace.test_root}/resources/eav.csv" }
  let(:sink) do
    ArcFurnace::EAVSink.new(
      filename: target_filename,
      product_id_property: 'id'
    )
  end

  before do
    sink.row({ 'id' => '111', 'Field 1' => 'boo bar', 'Field 2' => 'baz, bar' })
    sink.row({ 'id' => '222', 'Field 1' => 'baz', 'Field 2' => 'boo bar' })
    sink.finalize
  end

  after do
    File.delete(target_filename) if File.exists?(target_filename)
  end

  describe '#row' do
    it 'writes all rows' do
      expect(FileUtils.compare_file(target_filename, expected_output_path)).to eq true
    end
  end

end
