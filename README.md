# ArcFurnace
[![Gem Version](https://badge.fury.io/rb/arc-furnace.png)][gem]
[![Build Status](https://travis-ci.org/salsify/arc-furnace.svg?branch=master)][travis]

[gem]: https://rubygems.org/gems/arc-furnace
[travis]: http://travis-ci.org/salsify/arc-furnace

ArcFurnace melts, melds, and transforms your scrap data into perfectly crafted data for ingest into applications,
analysis, or whatnot. ArcFurnace simplifies simple ETL (Extract, Transform, Load) tasks for small to medium sets of data
using a programmatic DSL interface. Here's an example:

```ruby
class Transform < ArcFurnace::Pipeline

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

    outer_join :join_results,
               params: {
                   source: :product_attributes,
                   hash: :marketing_info
               }

    sink type: ArcFurnace::AllFieldsCSVSink,
         source: :join_results,
         params: { filename: :destination_name }

end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arc-furnace', github: 'salsify/arc-furnace'
```

And then execute:

    $ bundle

## Usage

ArcFurnace provides a few concepts useful to extracting and transforming data.

### Node Types Available

#### Pipelines

Pipelines define a a complete transformation and define a directed, acyclic graph of
operations that define how data is transformed. Each type of node in a `Pipeline` is defined below, but
a Pipelines defines the network of nodes that transform data.

#### Sources

A `Source` provides values to a `Pipeline`. A `Pipeline` may have many sources. Essentially, any nodes that
require a stream of data (`Hash`, `Transform`, `Join`, `Sink`) will have one.

#### Hashes

A `Hash` provides indexed access to a `Source` but pre-computing the index based on a key. The processing happens during the
prepare stage of pipeline processing. Hashes have a simple interface, `#get(primary_key)`, to requesting data. Hashes
are almost exclusively used as inputs to one side of joins.

#### Joins

An `InnerJoin` or an `OuterJoin` join two sources of data (one must be a `Hash`) based upon a key. By default the join
key is the key that the hash was rolled-up on, however, the `key_column` option on both `InnerJoin` and `OuterJoin`
may override this. Note the default join is an inner join, which will drop source rows if the hash does not contain
a matching row.

#### Filters

A `Filter` acts as a source, however, takes a source as an input and determines whether to pass each row to
the next downstream node by calling the `#filter` method on itself. There is an associated `BlockFilter` and
sugar on `Pipeline` to make this easy.

#### Transforms

A `Transform` acts as a source, however, takes a source as an input and transforms each input. The `BlockTransform` and
associated sugar in the `transform` method of `Pipeline` make this very easy (see the example above).

#### Unfolds

An `Unfold` acts as a source, however, takes a source as an input and produces multiple rows for that source as an output.
A common case for this is splitting rows into multiple rows depending upon their keys. The `BlockTransform` and associated
sugar in the `unfold` method of `Pipeline` make this fiarly easy (see `pipeline_spec.rb`).

#### Sinks

Each `Pipeline` has a single sink. Pipelines must produce data somewhere, and that data goes to a sink. Sinks
subscribe to the `#row(hash)` interace--each output row is passed to this method for handling.

### General pipeline development process

1. Define a source. Choose an existing `Source` implementation in this library (`CSVSource` or `ExcelSource`),
   extend the `EnumeratorSource`, or implement the `row()` method for a new source.
2. Define any transformations, or joins. This may cause you to revisit #1.
3. Define the sink. This is generally custom, or, may be one of the provided `CSVSink` types.
4. Roll it together in a `Pipeline`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODOs

1. Add examples for `ErrorHandler` interface.
2. Add sugar to define a `BlockTransform` on a `Source` definition in a `Pipeline`.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/arc-furnace/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
