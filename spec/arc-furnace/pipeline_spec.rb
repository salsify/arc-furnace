require 'spec_helper'

describe ArcFurnace::Pipeline do

  class Transform < ArcFurnace::Pipeline

    source :marketing_info_csv, type: ArcFurnace::CSVSource, params: { filename: :marketing_filename }

    transform :marketing_info_subsource, params: { source: :marketing_info_csv } do |row|
      row.delete('Name')
      row
    end

    unfold :marketing_info_source, params: { source: :marketing_info_subsource } do |row|
      if row['id'] == '111'
        first = row.deep_dup
        first['id'] = '666'
        [first, row.deep_dup]
      elsif row['id'] == '444'
        [row.deep_dup, row.deep_dup]
      else
        [row]
      end
    end

    source :product_attributes,
           type: ArcFurnace::MultiCSVSource,
           params: { filenames: :product_attribute_filenames }

    hash_node :marketing_info,
              params: {
                  key_column: :primary_key,
                  source: :marketing_info_source
              }

    inner_join :join_results,
               params: {
                   source: :product_attributes,
                   hash: :marketing_info
               }

    sink type: ArcFurnace::AllFieldsCSVSink,
         source: :join_results,
         params: { filename: :destination_name }

  end

  let(:marketing_source) { "#{ArcFurnace.test_root}/resources/marketing.csv" }
  let(:product_attributes) do
    [
      "#{ArcFurnace.test_root}/resources/empty_source.csv",
      "#{ArcFurnace.test_root}/resources/source1.csv",
      "#{ArcFurnace.test_root}/resources/source3.csv"
    ]
  end
  let(:target_filename) { Dir::Tmpname.create('output.csv') {} }

  let(:error_handler) { instance_spy("ErrorHandler", missing_primary_key: nil, missing_join_key: nil, duplicate_primary_key: nil, missing_hash_key: nil) }
  let(:instance) do
    Transform.instance(
        marketing_filename: marketing_source,
        product_attribute_filenames: product_attributes,
        destination_name: target_filename,
        primary_key: 'id',
        error_handler: error_handler
    )
  end
  let(:expected_output_path) { "#{ArcFurnace.test_root}/resources/expected_dsl_spec.csv" }
  after { File.delete(target_filename) if File.exists?(target_filename) }

  before do
    instance.execute
  end

  it 'writes all rows' do
    expect(FileUtils.compare_file(target_filename, expected_output_path)).to eq true
  end

  it 'registers duplicate keys' do
    expect(error_handler).to have_received(:duplicate_primary_key)
  end

end
