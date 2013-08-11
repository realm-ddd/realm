require 'spec_helper'

require 'realm/spec/messaging/fake_message_response'

module Realm
  module Messaging
    describe FakeMessageResponse do
      context "response is resolved with a value" do
        subject(:response) {
          FakeMessageResponse.new(resolve_with: response_message)
        }

        context "handler provided" do
          context "array of arguments" do
            let(:response_message) {
              { message_name: :foo, args: [ "one", "two", "three" ] }
            }

            let(:value) {
              response.on(
                foo: ->(a, b, c) { [ c, b, a ] },
                bar: ->() { raise "we shouldn't get :bar" }
              )
            }

            specify {
              expect(value).to be == %w[ three two one ]
            }
          end

          context "single argument (special case)" do
            let(:response_message) {
              { message_name: :foo, args: "only argument" }
            }

            let(:value) {
              response.on(
                foo: ->(a) { a.reverse },
                bar: ->() { raise "we shouldn't get :bar" }
              )
            }

            specify {
              expect(value).to be == "tnemugra ylno"
            }
          end

          context "single argument in response handler but array in canned response message" do
            let(:response_message) {
              { message_name: :foo, args: [ "one", "two", "three" ] }
            }

            let(:value) {
              response.on(
                foo: ->(a) { :_unused_ },
                bar: ->() { raise "we shouldn't get :bar" }
              )
            }

            specify "is treated as the multiple arument case" do
              expect { value }.to raise_error(ArgumentError, /3 for 1/)
            end
          end
        end

        context "handler not provided" do
          let(:response_message) {
            { message_name: :foo, args: :_unused_ }
          }

          let(:value) {
            response.on(
              bar: ->() { raise "we shouldn't get :bar" }
            )
          }

          # This is slighly abusing the current UnhandledMessageError
          # implementation, which expects a formal Realm message, not
          # a Ruby symbol - semantically it's still better than allowing
          # a KeyError to leak out though
          specify {
            expect {
              value
            }.to raise_error(UnhandledMessageError, /foo/)
          }
        end
      end

      context "response raises an error" do
        let(:error) { NameError.new("something went wrong") }

        subject(:response) {
          FakeMessageResponse.new(raise_error: error)
        }

        example do
          expect {
            response.on(foo: ->() { :_unused_ })
          }.to raise_error(NameError) { |error|
            expect(error).to be(error)
          }
        end
      end

      context "neither a response nor an error is provided" do
        it "can't be constructed" do
          expect {
            FakeMessageResponse.new
          }.to raise_error(ArgumentError,
            "You must provide either a respond_with: or a raise_error: argument"
          )
        end
      end
    end
  end
end
