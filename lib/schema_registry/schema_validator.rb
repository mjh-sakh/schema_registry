# frozen_string_literal: true

require_relative '../schemas/_register'


# Schema Validation
class SchemaValidator
  class SchemaValidationFailed < StandardError; end

  include Register

  def initialize(message, schema_name)
    @message = message
    @subject = @message
    begin
      @validator = method(schema_name.downcase.to_sym)
    rescue
      raise ArgumentError, "Schema with name '#{schema_name}' not found in the library."
    end
  end

  # @raise SchemaValidationFailed of three different kinds
  #        KeyError, TypeError or ArgumentError
  def validate!
    @validator.call
    true

  rescue KeyError, TypeError, ArgumentError
    raise SchemaValidationFailed, $!, $!.backtrace
  end

  # error is not raised
  # @return false if fails
  def validate
    validate!

  rescue SchemaValidationFailed
    false
  end

  private

  def verify(key, value_check = nil)
    message_value = @subject.fetch(key)
    case value_check
    when NilClass # not specified, passing
    when Class # type check
      raise TypeError, "Type #{value_check} != #{message_value.class} for '#{key}'" unless message_value.is_a? value_check
    when Proc # used only for optional type check
      raise ArgumentError, "Type is not #{message_value.class} or nil for '#{key}'" if value_check.call(message_value)
    when Method # special check
      raise ArgumentError, "Special check '#{value_check.name}' failed for '#{key}'" if value_check.call(message_value)
    else # value check
      raise ArgumentError, "Value #{value_check} != #{message_value} for '#{key}'" if message_value != value_check
    end
  end

  alias v verify

  def optional(type)
    check = ->(type, value) { !value.is_a? type and !value.nil? }.curry
    check.call(type)
  end

  # https://stackoverflow.com/a/47511286/12488601
  def uuid?(uuid)
    uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
    !uuid_regex.match?(uuid.to_s.downcase)
  end

end
