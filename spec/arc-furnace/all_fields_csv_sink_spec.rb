require 'spec_helper'

describe ArcFurnace::AllFieldsCSVSink do
  let(:target_filename) { Dir::Tmpname.create('output.csv') {} }
  let(:expected_output_path) { "#{ArcFurnace.test_root}/resources/with_duplicates.csv" }
  let(:sink) { ArcFurnace::AllFieldsCSVSink.new(filename: target_filename) }
  after { File.delete(target_filename) if File.exists?(target_filename) }

  before do
    sink.prepare
    sink.row({ "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" })
    sink.row({ "id" => "222", "Field 1" => [ "baz", "bag" ], "Field 2" => "boo bar" })
    sink.finalize
  end

  it 'writes all rows' do
    expect(FileUtils.compare_file(target_filename, expected_output_path)).to eq true
  end

end
