require 'arc-furnace'
require 'ice_nine'
require 'ice_nine/core_ext/object'
require 'pry'
require 'axlsx'

module ArcFurnace
  def self.test_root
    __dir__ + '/arc-furnace'
  end
end

RSpec::Matchers.define :key_included_in do |set|
  match { |actual| set.include?(actual[:key]) }
end

RSpec.shared_examples 'node operation registered no errors' do
  it 'registered no errors' do
    expect(error_handler).not_to have_received(:missing_primary_key)
    expect(error_handler).not_to have_received(:missing_join_key)
    expect(error_handler).not_to have_received(:missing_hash_key)
    expect(error_handler).not_to have_received(:duplicate_primary_key)
  end
end
