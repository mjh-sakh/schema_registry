# frozen_string_literal: true

require 'securerandom'

RSpec.describe SchemaRegistry do
  it 'has a version number' do
    expect(SchemaRegistry::VERSION).not_to be nil
  end

  # it utilizes demo schemas provided as part of the gem
  context 'SchemaValidator:' do
    let(:schema) { :demo_schema_v1 }

    context 'when non-existing schema provided' do
      let(:wrong_schema) { :wrong_one }

      it 'raises error' do
        expect { SchemaValidator.new({}, wrong_schema).validate! }
          .to raise_error(ArgumentError)
      end
    end

    context 'with different messages' do
      let(:schema_v2) { :demo_schema_v2 }
      let(:correct_message) do
        {
          name: 'Luke',
          id: SecureRandom.uuid,
          age: 143,
          gender: nil,
          planets: %w[Tatooine Coruscant],
          skills: {
            power: 99
          }
        }
      end
      let(:incorrect_message) { { name: 15 } }

      it 'returns true for correct message' do
        expect(SchemaValidator.new(correct_message, schema).validate!).to be true
      end

      it 'returns false or raises error when incorrect' do
        expect(SchemaValidator.new(incorrect_message, schema).validate).to be false
        expect { SchemaValidator.new(incorrect_message, schema).validate! }
          .to raise_error SchemaValidator::SchemaValidationFailed
      end

      it 'verification fails when new schema is not backward compatible' do
        expect(SchemaValidator.new(correct_message, schema_v2).validate).to be false
      end
    end

    context 'specifics:' do
      let(:schema) { :test_schema }

      class ValidatorTester < SchemaValidator
        def initialize(message, schema_name, test_key, test_value_check)
          define_singleton_method 'test_schema' do
            verify test_key, test_value_check
          end
          super(message, schema_name)
        end
      end

      context 'when key is missing' do
        let(:test_key) { :name }
        let(:test_value_check) { String }
        let(:good) { { name: 'Luke' } }
        let(:bad) { {} }

        it 'fails with KeyError' do
          expect(ValidatorTester.new(good, schema, test_key, test_value_check)
                                .validate!).to be true

          expect { ValidatorTester.new(bad, schema, test_key, test_value_check)
                                  .validate! }.to raise_error(/key not found/)
        end
      end

      context 'when class is wrong' do
        let(:test_key) { :name }
        let(:test_value_check) { String }
        let(:good) { { name: 'Luke' } }
        let(:bad) { { name: 44 } }

        it 'fails with TypeError' do
          expect(ValidatorTester.new(good, schema, test_key, test_value_check)
                                .validate!).to be true

          expect { ValidatorTester.new(bad, schema, test_key, test_value_check)
                                  .validate! }.to raise_error(/Type .+ !=/)
        end
      end

      context 'when value is wrong' do
        let(:test_key) { :name }
        let(:test_value_check) { 'Luke' }
        let(:good) { { name: 'Luke' } }
        let(:bad) { { name: 'Bob' } }

        it 'fails with KeyError' do
          expect(ValidatorTester.new(good, schema, test_key, test_value_check)
                                .validate!).to be true

          expect { ValidatorTester.new(bad, schema, test_key, test_value_check)
                                  .validate! }.to raise_error(/Value .+ !=/)
        end
      end
    end
  end
end