require 'facets/hash/reverse_merge'

module Realm
  module Domain
    class DomainError < RuntimeError; end # Purely for naming/groupng purposes

    class InvalidOperationError < DomainError; end
    class ConstructionError < DomainError; end

    module AggregateRoot
      def self.extended(host)
        host.class_eval do
          include InstanceMethods
        end
      end

      def create(attributes)
        allocate.tap do |aggregate_root|
          aggregate_root.initialize_aggregate_root
          aggregate_root.send(:initialize, attributes)
        end
      end

      def load_from_history(events)
        allocate.tap do |aggregate_root|
          aggregate_root.initialize_aggregate_root
          events.each do |event|
            aggregate_root.apply(event)
          end
        end
      end

      module InstanceMethods
        attr_reader :uuid, :uncommitted_events

        def initialize_aggregate_root
          @uncommitted_events = [ ]
        end

        def fire(event_type, attributes = { })
          event = event_factory.build(event_type, attributes.reverse_merge(uuid: uuid))
          apply(event)
          uncommitted_events << event
        end

        def apply(event)
          send(:"apply_#{event.event_type}", event)
        end

        private

        def invalid_operation(message)
          raise InvalidOperationError.new(message)
        end

        def construction_error(message)
          raise ConstructionError.new(message)
        end
      end
    end
  end
end
