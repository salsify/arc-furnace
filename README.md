# ArcFurnace

ArcFurnace melts, melds, and transforms your scrap data into perfectly crafted data for ingest into applications, 
analysis, or whatnot. ArcFurnace simplifies simple ETL (Extract, Transform, Load) tasks for small to medium sets of data
using a programmatic DSL interface. Here's an example:

```ruby
class Transform < ArcFurnace::DSL

source :marketing_info_csv, type: ArcFurnace::CSVSource, params: { filename: :marketing_filename }

transform :marketing_info_source, params: { source: :marketing_info_csv } do |row|
  row.delete('Name')
  row
end

source :product_attributes,
       type: ArcFurnace::MultiCSVSource,
       params: { filenames: :product_attribute_filenames }

hash_node :marketing_info,
          params: {
              key_column: :primary_key,
              source: :marketing_info_source
          }

equijoin :join_results,
         params: {
             left: :product_attributes,
             right: :marketing_info
         }

sink type: ArcFurnace::AllFieldsCSVSink,
     source: :join_results,
     params: { filename: :destination_name }

end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arc-furnace'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arc-furnace

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/arc-furnace/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
