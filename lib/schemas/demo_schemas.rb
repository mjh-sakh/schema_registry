# frozen_string_literal: true

module DemoSchemas

  def demo_schema_v1
    v :name, String
    v :id, method(:uuid?)
    v :age, Integer
    v :gender, optional(String)
    v :planets, Array
    @subject = v :skills, Hash
    v :power, Integer
  end

  def demo_schema_v2
    v :name, String
    v :age, Integer
    v :planets, Array
    @subject = v :skills, Hash
    v :power, Integer
    v :lightsaber_color, String
  end

end
