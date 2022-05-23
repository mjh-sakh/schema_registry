# frozen_string_literal: true

# Single point to reference your schema specifications
module Register
  # require then include

  # Demo schema specifications
  require_relative 'demo_schemas'
  include DemoSchemas
end