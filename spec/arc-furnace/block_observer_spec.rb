require 'spec_helper'

describe ArcFurnace::BlockObserver do
  let(:subsource) { ArcFurnace::CSVSource.new(filename: "#{ArcFurnace.test_root}/resources/source1.csv") }
  let(:source) do
    ArcFurnace::BlockObserver.new(
        source: subsource,
        block: ->(row, params) do
          params.fetch(:registry).add(row["id"])
        end
    )
  end
  let(:registry) { Set.new }
  before do
    source.params = { registry: registry }
    source.prepare
  end

  describe '#row' do
    it 'feeds all rows' do
      expect(source.row.to_hash).to eq ({ "id" => "111", "Field 1" => "boo bar", "Field 2" => "baz, bar" })
      expect(source.row.to_hash).to eq ({ "id" => "222", "Field 1" => "baz", "Field 2" => "boo bar" })
      expect(source.row).to be_nil
      expect(registry).to eq Set.new(['111', '222'])
    end
  end

end
