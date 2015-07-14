require 'spec_helper'

describe ArcFurnace::FixedColumnCSVSink do
  let(:target_filename) { Dir::Tmpname.create('output.csv') {} }
  let(:expected_output_path) { "#{ArcFurnace.test_root}/resources/fixed_column_expected.csv" }
  let(:sink) { ArcFurnace::FixedColumnCSVSink.new(filename: target_filename, fields: { "id" => 1, "Field 1" => 2, "Field 2" => 1 }) }
  after { File.delete(target_filename) if File.exists?(target_filename) }

  before do
    sink.row({ "Field 1" => "boo bar", "Field 2" => [ "baz, bar", "biz" ], "id" => "111" })
    sink.row({ "id" => "222", "Field 1" => [ "baz", "bag", "boo" ], "Field 2" => "boo bar" })
    sink.row({ "id" => "333", "Field 5" => "bar" })
    sink.finalize
  end

  describe '#row' do
    it 'writes all rows' do
      expect(FileUtils.compare_file(target_filename, expected_output_path)).to eq true
    end
  end

end
