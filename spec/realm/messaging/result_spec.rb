require 'spec_helper'

require 'realm/messaging/result'

module Realm
  module Messaging
    describe Result, async: true do
      # Strict evaluation because otherwise we might set up a race condition
      subject!(:result) { Result.new }

      after(:each) { result.terminate }


      # This context taken from FakeMessageResponse
      context "handler provided" do
        context "array of arguments" do
          context "when the handlers are provided first" do
            let(:value_thread) {
              Thread.new {
                result.on(
                  foo: ->(a, b, c) { [ c, b, a ] },
                  bar: ->() { raise "we shouldn't get :bar" }
                )
              }
            }

            let(:value) { value_thread.value }

            def start_value_thread
              value_thread
            end

            def wait_for_handlers_to_be_defined
              start_value_thread
              sleep(0.001) until value_thread.status == "sleep"
            end

            before(:each) do
              wait_for_handlers_to_be_defined
            end

            example do
              result.foo("one", "two", "three")
              expect(value).to be == %w[ three two one ]
            end
          end

          # No need for multiple threads in this context
          context "when the value is resolved first" do
            example do
              result.foo("one", "two", "three")

              value =
                result.on(
                  foo: ->(a, b, c) { [ c, b, a ] },
                  bar: ->() { raise "we shouldn't get :bar" }
                )

              expect(value).to be == %w[ three two one ]
            end
          end
        end

        context "single argument (special case)" do
          let(:value) {
            result.on(
              foo: ->(a) { a.reverse },
              bar: ->() { raise "we shouldn't get :bar" }
            )
          }

          specify {
            result.foo("only argument")
            expect(value).to be == "tnemugra ylno"
          }
        end

        context "single argument in response handler but multiple args provided" do
          let(:response_message) {
            { message_name: :foo, args: [  ] }
          }

          let(:value) {
            result.on(
              foo: ->(a) { :_unused_ },
              bar: ->() { raise "we shouldn't get :bar" }
            )
          }

          specify "is treated as the multiple arument case" do
            result.foo("one", "two", "three")
            expect { value }.to raise_error(ArgumentError, /3 for 1/)
          end
        end
      end

      # This context taken from FakeMessageResponse
      context "handler not provided" do
        let(:value) {
          result.on(
            bar: ->() { raise "we shouldn't get :bar" }
          )
        }

        # This is slighly abusing the current UnhandledMessageError
        # implementation, which expects a formal Realm message, not
        # a Ruby symbol - semantically it's still better than allowing
        # a KeyError to leak out though
        specify {
          expect {
            result.foo
            value
          }.to raise_error(UnhandledMessageError, /foo/)
        }
      end
    end
  end
end