require 'spec_helper'

require 'realm/domain/validation'

module Realm
  module Domain
    module Validation
      describe EntityValidator, "prototype" do
        subject(:prototype) { EntityValidator.new }

        it "can't be used immediately" do
          expect {
            prototype.validate(:anything)
          }.to raise_error(ValidatorStateError, "Validator has not been prepared - use #dup first")
        end
      end

      describe EntityValidator, "empty" do
        let(:prototype) { EntityValidator.new }
        subject(:validator) { prototype.dup }

        it "validates anything" do
          expect { validator.validate(:this_is_not_an_entity) }.to_not raise_error
          expect(validator.entity_valid?).to be_true
        end
      end

      describe EntityValidator do
        let(:entity) {
          double("Entity", declare_foo: nil, declare_bar: nil)
        }

        let(:foo_validator) { RegexValidator.new(/^[a-z]+$/, name: :alphabetic_regex) }
        let(:bar_validator) { RegexValidator.new(/^[0-9]+$/, name: :numeric_regex) }

        let(:prototype) {
          EntityValidator.new(
            validators: { foo: foo_validator, bar: bar_validator },
            messages: {
              foo: { alphabetic_regex:  "Foo must be alphabetic" },
              bar: { numeric_regex:     "Bar must be only digits" }
            }
          )
        }

        subject(:validator) { prototype.dup }

        describe "#dup" do
          let!(:new_validator) { validator.dup }

          let(:invalid_entity) {
            double("Invalid Entity").tap do |entity|
              entity.stub :declare_foo do |listener|
                listener.attribute_declared(:foo, "123")
              end
              entity.stub :declare_bar do |listener|
                listener.attribute_declared(:bar, "abc")
              end
            end
          }

          it "clones the validator" do
            validator.validate(invalid_entity)

            expect {
              new_validator.validate(invalid_entity)
            }.to_not raise_error
          end

          it "clones the inner validators correctly" do
            new_validator.validate(invalid_entity)

            expect(validator.entity_valid?).to be_true
            expect(validator.message).to be_nil

            expect(new_validator.entity_valid?).to be_false
            expect(new_validator.message).to be_a(String)
          end
        end

        describe "trying to re-use a validator" do
          it "raises an error" do
            validator.validate(entity)
            expect {
              validator.validate(entity)
            }.to raise_error(RuntimeError, "Validator has already been used")
          end
        end

        describe "#validate" do
          it "tells the entity to declare all the attributes we want to validate" do
            validator.validate(entity)
            expect(entity).to have_received(:declare_foo)
            expect(entity).to have_received(:declare_bar)
          end

          # This is a really odd way to describe the behaviour, caused by cloning
          # and configuring the prototypes inside the Entity Validator. Maybe this
          # should be done before passing them in, although that seems to put the
          # responsibility in the wrong place.
          it "passed in correctly-wired listeners" do
            entity.should_receive(:declare_foo) do |validation_listener|
              validation_listener.attribute_declared(:foo, "not valid!")
            end

            validator.validate(entity)

            expect(validator.entity_valid?).to be_false
          end
        end

        describe "#entity_valid?" do
          context "no violations" do
            specify {
              expect(validator.entity_valid?).to be_true
            }
          end

          context "a violation" do
            example do
              validator.attribute_failed_validation(:foo, :alphabetic_regex)
              expect(validator.entity_valid?).to be_false
            end
          end

          context "multiple violations" do
            example do
              validator.attribute_failed_validation(:foo, :alphabetic_regex)
              validator.attribute_failed_validation(:bar, :numeric_regex)
              expect(validator.entity_valid?).to be_false
            end
          end
        end

        describe "#message" do
          context "no violations" do
            example do
              expect(validator.message).to be_nil
            end
          end

          context "a violation" do
            example do
              validator.attribute_failed_validation(:foo, :alphabetic_regex)
              expect(validator.message).to be == "Foo must be alphabetic"
            end
          end

          context "multiple violations" do
            example do
              validator.attribute_failed_validation(:foo, :alphabetic_regex)
              validator.attribute_failed_validation(:bar, :numeric_regex)
              expect(validator.message).to be == "Foo must be alphabetic; Bar must be only digits"
            end
          end
        end
      end
    end
  end
end
