# Json::Inflator

This ruby gem actually contains the necessary logic to recycle a JSON object. 
This means that it rebuilds a JSON that has been decycled:

```json
[ { "id": 231, "name": "Test" }, { "$ref": "$[0]" } ]
```

To:

```json
[ { "id": 231, "name": "Test" }, { "id": 231, "name": "Test" } ]
```

Please note that both JSON objects point to same memory reference.
The result is a Hash with circular references.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json-inflator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json-inflator

## Usage

### Quick Start

Create an object of class Json::Inflator::Parser and process your json:

```ruby
  sample_hash = [ { "id" => 231, "name" => "Test" }, { "$ref" => "$[0]" } ]
  parser = Json::Inflator::Parser.new
  result = parser.process! sample_hash
  # result contains:
  # [ { "id" => 231, "name": "Test" }, { "id" => 231, "name" => "Test" } ]
```

Take in account that the method #process! mutates the hash or array passed as a parameter. 
Your final result is the output of the method.

### Recycle JPath (Default)

By default the parser will resolve references by JSON Path as in the above examples. You can tell it to do it in a more explicit way:

```ruby
  parser = Json::Inflator::Parser.new
  result = parser.process! sample_hash, :j_path
```

### Static Reference

Another proposal to resolve the circular references is to mark every object with an $id. For arrays, use a hash with $values and $id. 
The $values key will contain the elements of the array.

```ruby
  sample_hash = { 
    "$values" =>
      [ { "$id" => "1", "id" => 231, "name" => "Test" }, { "$ref" => "1" } ], 
    "$id" => "0" 
  }
  parser = Json::Inflator::Parser.new
  result = parser.process! sample_hash, :static_reference
  # result contains:
  # [ { "id" => 231, "name": "Test" }, { "id" => 231, "name" => "Test" } ]
```

### Customize

When you are recycling you have several settings:

```ruby
  parser = Json::Inflator::Parser.new({
    settings: { 
      root_symbol: '$', # Just for JPath, change the root symbol. By default is $
      mode: :j_path, # The way the JSON is received. By default it is j_path
      strip_identifiers: true # Just for static reference, strips $id keys from resulting hash
    }
  })
```

If you want to customize the object processing in the recursive step, just pass a class in the constructor:

```ruby
  class MyStaticReferenceHandler < StaticReferenceHandler

    # Do whatever you need here
    def process_object!( json_hash )
      super()
    end

  end

  parser = Json::Inflator::Parser.new({ object_handler_class: MyStaticReferenceHandler })
```

To use the JPath logic just inherit from JPathHandler

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/json-inflator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
