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

Call inflate_json! method for a decycled array or hash:

```ruby
  sample_json = [ { "id" => 231, "name" => "Test" }, { "$ref" => "$[0]" } ]
  result = sample_json.inflate_json!
  # result contains:
  [ { "id" => 231, "name": "Test" }, { "id" => 231, "name" => "Test" } ]
```

Take in account that the method #inflate_json! mutates the object. 
Your final result is the output of the method.

### Recycle JPath (Default)

By default the parser will resolve references by JSON Path as in the above examples. You can tell it to do it in a more explicit way:

```ruby
  result = sample_json.inflate_json! settings: { mode: :j_path }
```

### Static Reference

Another proposal to resolve the circular references is to mark every object with an $id. For arrays, use a hash with $values and $id. 
The $values key will contain the elements of the array.

```ruby
  sample_json = [ { "$id" => "1", "id" => 231, "name" => "Test" }, { "$ref" => "1" } ]
  result = sample_json.inflate_json! settings: { mode: :static_reference }
  # result contains:
  [ { "id" => 231, "name": "Test" }, { "id" => 231, "name" => "Test" } ]
```

### Array Preservation
The provided JSON maybe storing references for arrays also. By default, 'preserve_arrays' setting is true so it will check for
arrays when resolving a reference. In the case of static references, an array must be provided in the following way in order
to be tracked:

```ruby
  sample_json = {
    "$values" =>
      [ 
        { "$id" => "1", "id" => 231, "name" => "Test" },
        {
          "$values" =>
            [ 
              { "$id" => "3", "id" => 232, "name" => "Test A" }, 
              { "$id" => "4", "id" => 233, "name" => "Test B" }
            ],
          "$id" => "2" 
        },        
        { "$ref" => "2" } 
      ], 
    "$id" => "0" 
  }
  result = sample_json.inflate_json! settings: { mode: :static_reference, preserve_arrays: true }
  # result contains:
  [ 
    { "$id" => "1", "id" => 231, "name" => "Test" },
    [ 
      { "$id" => "3", "id" => 232, "name" => "Test A" }, 
      { "$id" => "4", "id" => 233, "name" => "Test B" }
    ],
    [ 
      { "$id" => "3", "id" => 232, "name" => "Test A" }, 
      { "$id" => "4", "id" => 233, "name" => "Test B" }
    ]
  ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/json-inflator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
