# SchemaRegistry

Schema Registry is a collection of micro service message's specifications. 
This gem is a tool to create and maintain this spec collection.

Please find this good read about why you want to use schema registry:
[Using a schema registry to ensure data consistency between microservices](https://www.redhat.com/architect/schema-registry).

This gem is designed to check your messages before serialization.
It works with messages that are composed in a form of Hash. 

## Installation

You need to have this gem in your repository. It's designed to be modified, hosted at your versions control and required by your services.

So `git clone` it or `fork` it instead of installation.

Make sure your add your source to Gemfile:   

    $ gem 'schema_registry, git: your-repository

## Usage

### Set up

Schema Registry is a collection of your specifications, therefore first step is actually to create one. 

Specifications are described in separate Modules that are used by the gem. 

1. Create new module under `lib/schemas` folder
2. Write down spec

```ruby
def character_created # this will be used as a name to look up your schema in the register
  # general structure is following
  # verify key, type or other check
  verify :name, String
  # there is an alias for verify - 'v', to make notation more concise
  v :age, Integer
  # if there is nested group, then one need to change analyzed subject as following
  @subject = v :data, Hash
  # then everything as usual 
  v :id, method(uuid?) # one can define predicate functions and put them as a verification method
  v :date, optional(DateTime) # optional allows field value to be nil
  v :home # or you can skip second argument for verify and it will check only key presence in the message
  # if one need to go back to top level, then reset subject back to the message
  @subject = @message
  @subject = v :additional_data, optional(Hash)
  # you can use normal logic here
  return if @subject.nil?
  v :favorite_food, 'Banana' # you can enforce data to be specific value
end
```

Refer demo items and rspec files. 

### Utilization

Validate message to be per spec before publishing it to the broker.
Use either `validate!` to get an exception, or `validate` to get `false` on failure.

```ruby
require 'schema_registry'

message = {
  name: 'Luke',
  age: 15,
  data: {
    id: SecureRandom.uuid,
    date: nil
    },
  additional_data: nil
}

if SchemaValidator.new(message, :character_created).validate 
  MessageBrokerClient.publish(message)
end
```

## Notes

Schema naming: currently there is a common namespace for all schema modules, therefore it may result in a clash if names are the same.
Thus it's recommended to use service name as a prefix, e.g. `auth_account_created`.

Validation checks that all fields in the spec are present in the message. 
Other fields that may be in the message, they will be ignored.

Available checks:
- specific values, e.g. 23, 'Banana' - validation passes only if message and spec values are the same
- types, e.g. String, Integer - `is_a?` method is used to verify that message values is of certain class
- `optional` - allows to accept nil value as valid one, but key still has to be present in the message
- `uuid?` - custom predicate to verify that string is an uuid

## Customization

You can define your own checks as a predicates (functions that return true of false). 
Then use `mehtod(your_function)` to use it as a check value. 

## Contributing

Please use issues for bug reports and feature requests, and pull requests are always welcome! 

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).