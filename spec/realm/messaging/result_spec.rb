require 'spec_helper'

require 'realm/messaging/result'

module Realm
  module Messaging
    describe Result, async: true do
      let(:message_type_foo) {
        MessageType.new(:foo, properties: { foo_value: String })
      }

      let(:message_type_bar) {
        MessageType.new(:bar, properties: { bar_value: String })
      }

      # Strict evaluation because otherwise we might set up a race condition
      subject!(:result) {
        Result.new(
          responses: {
            foo: message_type_foo,
            bar: message_type_bar,
          }
        )
      }

      after(:each) { result.terminate }

      describe "#understand_response?" do
        context "the response is known" do
          example do
            expect(result.understand_response?(:foo)).to be_true
          end
        end

        context "the response is not known" do
          example do
            expect(result.understand_response?(:kaboom)).to be_false
          end
        end

        describe "respond_to?" do
          it "is an alias (but understand_response? is semantically richer)" do
            expect(result.respond_to?(:foo)).to be_true
            expect(result.respond_to?(:kaboom)).to be_false
          end

          it "behaves like the basic respond_to?" do
            expect(result.respond_to?(:to_s)).to be_true
          end
        end
      end

      describe "resolving with a message the Result understands" do
        context "when the attributes are valid" do
          context "single argument" do
            let(:value) {
              result.on(
                foo: ->(attributes) { attributes[:foo_value].reverse },
                bar: ->() { raise "we shouldn't get :bar" }
              )
            }

            specify {
              result.foo(foo_value: "some foo value")
              expect(value).to be == "eulav oof emos"
            }
          end

          context "mismatched arity length in the handler" do
            def pass_handlers_to_result
              result.on(
                foo: ->() { :_unused_ },
                bar: ->() { raise "we shouldn't get :bar" }
              )
            end

            let(:value) {
              pass_handlers_to_result
            }

            it "raises an ArgumentError" do
              result.foo(foo_value: "some foo value")
              expect { value }.to raise_error(ArgumentError, /1 for 0/)
            end

            it "doesn't crash the actor" do
              result.foo(foo_value: "some foo value")

              # Specific negative expections are deprecated in RSpec, sigh
              expect {
                # First call might crash the actor
                pass_handlers_to_result rescue nil
                begin
                  # Second call will raise an error
                  pass_handlers_to_result
                rescue Exception => e
                  # Swallow it unless it's a dead actor, in which case we care
                  raise if e.is_a?(Celluloid::DeadActorError)
                end
              }.to_not raise_error
            end
          end
        end

        context "when the attributes are invalid" do
          it "raises an error" do
            expect {
              result.foo(wrong_foo_value: "some foo value")
            }.to raise_error(MessagePropertyError) { |error|
              expect(error.message).to include(" foo_value")
              expect(error.message).to include(" wrong_foo_value")
            }
          end

          it "doesn't crash the actor" do
            expect {
              result.foo(wrong_foo_value: "some foo value") rescue nil
              begin
                result.foo(foo_value: "some foo value")
              rescue Exception => e
                raise if e.is_a?(Celluloid::DeadActorError)
              end
            }.to_not raise_error
          end
        end
      end

      describe "attempting to resolve with an unknown message" do
        it "raises an error" do
          expect {
            result.unknown_response
          }.to raise_error(UnhandledMessageError, /unknown_response/)
        end

        it "doesn't crash the actor" do
          expect {
            result.unknown_response rescue nil
            begin
              result.unknown_response
            rescue Exception => e
              raise if e.is_a?(Celluloid::DeadActorError)
            end
          }.to_not raise_error
        end
      end

      describe "asynchronous usage (providing the handlers first)" do
        let(:value_thread) {
          Thread.new {
            result.on(
              foo: ->(attributes) { attributes[:foo_value].reverse },
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
          result.foo(foo_value: "some foo value")
          expect(value).to be == "eulav oof emos"
        end
      end

      describe "errors in the handler configuration" do
        context "superflous handler provided" do
          def pass_handlers_to_result
            result.on(
              foo: ->(result) { :_unused_ },
              baz: ->(result) { :_unused_ }
            )
          end

          it "is an error" do
            result.foo(foo_value: "some foo value")

            expect {
              pass_handlers_to_result
            }.to raise_error(UnknownMessageTypeError, /baz/)
          end

          it "doesn't crash the actor" do
            result.foo(foo_value: "some foo value")

            expect {
              pass_handlers_to_result rescue nil
              begin
                pass_handlers_to_result
              rescue Exception => e
                raise if e.is_a?(Celluloid::DeadActorError)
              end
            }.to_not raise_error
          end
        end

        # This context taken from FakeMessageResponse
        context "handler not provided" do
          def pass_handlers_to_result
            result.on(
              bar: ->() { raise "we shouldn't get :bar" }
            )
          end

          let(:value) {
            pass_handlers_to_result
          }

          # This is slighly abusing the current UnhandledMessageError
          # implementation, which expects a formal Realm message, not
          # a Ruby symbol - semantically it's still better than allowing
          # a KeyError to leak out though
          it "raises an error" do
            expect {
              result.foo(foo_value: "some foo value")
              value
            }.to raise_error(UnhandledMessageError, /foo/)
          end

          it "doesn't crash the actor" do
            result.foo(foo_value: "some foo value")

            expect {
              pass_handlers_to_result rescue nil
              begin
                pass_handlers_to_result
              rescue Exception => e
                raise if e.is_a?(Celluloid::DeadActorError)
              end
            }.to_not raise_error
          end
        end
      end
    end
  end
end