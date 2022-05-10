# DeepStack Ruby Wrapper

[![GitHub version](https://badge.fury.io/gh/jimtng%2Fdeepstack-ruby.svg)](https://github.com/jimtng/deepstack-ruby)
[![Gem Version](https://badge.fury.io/rb/deepstack.svg)](https://rubygems.org/gems/deepstack)

A Ruby wrapper for [DeepStack](https://www.deepstack.cc/) HTTP API

## Usage

Install the gem with `gem install deepstack`

```ruby
require 'deepstack'

deepstack = DeepStack.new('http://192.168.1.10:2000')
image = File.read('image.jpg')

# Find bounding rects for objects
predictions = deepstack.detect_objects(image) 
# => [{"confidence"=>0.86599416, "label"=>"dog", "y_min"=>355, "x_min"=>648, "y_max"=>540, "x_max"=>797},
#     {"confidence"=>0.918332, "label"=>"person", "y_min"=>113, "x_min"=>442, "y_max"=>524, "x_max"=>601},
#     {"confidence"=>0.9292374, "label"=>"person", "y_min"=>83, "x_min"=>294, "y_max"=>521, "x_max"=>447}]

# Find bounding rects for faces
faces = deepstack.detect_faces(image)
# => [{"confidence"=>0.86419886, "y_min"=>236, "x_min"=>876, "y_max"=>730, "x_max"=>1203},
#     {"confidence"=>0.8811783, "y_min"=>164, "x_min"=>1617, "y_max"=>692, "x_max"=>1985}]

# Register a face for face recognition
deepstack.register_face('user_name', image)

# Perform a face recognition, return identified userids
faces = deepstack.recognize_face(image)
# => [{"confidence"=>0, "userid"=>"unknown", "y_min"=>236, "x_min"=>876, "y_max"=>730, "x_max"=>1203},
#     {"confidence"=>0.9824197, "userid"=>"user_name", "y_min"=>164, "x_min"=>1617, "y_max"=>692, "x_max"=>1985}]

# Perform Scene recognition
scene = deepstack.identify_scene(image)
# => {"success"=>true, "confidence"=>0.27867314, "label"=>"archive", "duration"=>0}
```

See the [documentation](https://www.rubydoc.info/gems/deepstack) for more details.

## Development

A Linux development machine is needed in order to run the tests. The test will launch a DeepStack docker instance
to test against. By default, the deepstack docker will listen on port `81`. To change this, copy `rakelib/deepstack.yml.sample` to `rakelib/deepstack.yml` 
and change the port number as required.

To run the tests run `rake`.

To manually stop the DeepStack docker instance, run `rake deepstack:stop`

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jimtng/deepstack-ruby.

## License

The gem is available as open source under the terms of the EPL 2.0 License
