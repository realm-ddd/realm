require 'facets/kernel/constant'

module Realm
  module Domain
    def self.event_store_repository(aggregate_root_class_name, &block)
      Class.new do
        extend EventStoreRepository

        aggregate_root_class aggregate_root_class_name

        class_eval(&block) if block
      end
    end

    module EventStoreRepository
      def self.extended(host)
        host.class_eval do
          include InstanceMethods
        end
      end

      def aggregate_root_class(class_name)
        @aggregate_root_class_name = class_name
      end

      def domain_term_for(generic_term, domain_term)
        alias_method domain_term, generic_term
        private generic_term
      end

      def new(event_store)
        allocate.tap do |repository|
          repository.send(:initialize, _aggregate_root_class, event_store)
        end
      end

      private

      def _aggregate_root_class
        Kernel.constant(@aggregate_root_class_name)
      end

      module InstanceMethods
        def initialize(aggregate_root_class, event_store)
          @aggregate_root_class = aggregate_root_class
          @event_store          = event_store
        end

        def save(aggregate_root)
          @event_store.save_events(aggregate_root.uuid, aggregate_root.uncommitted_events)
        end

        def update(aggregate_root)
          save(aggregate_root)
        end

        def get_by_id(uuid)
          @aggregate_root_class.load_from_history(@event_store.history_for_aggregate(uuid))
        end
      end
    end
  end
end