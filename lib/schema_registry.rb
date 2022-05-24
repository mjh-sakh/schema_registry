# frozen_string_literal: true

require_relative "schema_registry/version"
require_relative "schema_registry/schema_validator"

# loads all files from schemas folder
Dir.glob( File.join( File.dirname(__FILE__), 'schemas', '**', '*.rb' ), &method(:require) )

# common namespace
module SchemaRegistry
  #include all schemas
  SchemaValidator.include(DemoSchemas)
end
