# frozen_string_literal: true
module Hako
  module Schedulers
    class EcsDefinitionComparator
      def initialize(expected_container)
        @expected_container = expected_container
      end

      CONTAINER_KEYS = %i[image cpu memory links docker_labels].freeze
      PORT_MAPPING_KEYS = %i[container_port host_port protocol].freeze
      ENVIRONMENT_KEYS = %i[name value].freeze
      MOUNT_POINT_KEYS = %i[source_volume container_path read_only].freeze

      def different?(actual_container)
        unless actual_container
          return true
        end
        if different_members?(@expected_container, actual_container, CONTAINER_KEYS)
          return true
        end
        if different_array?(@expected_container, actual_container, :port_mappings, PORT_MAPPING_KEYS)
          return true
        end
        if different_array?(@expected_container, actual_container, :environment, ENVIRONMENT_KEYS)
          return true
        end
        if different_array?(@expected_container, actual_container, :mount_points, MOUNT_POINT_KEYS)
          return true
        end

        false
      end

      private

      def different_members?(expected, actual, keys)
        keys.each do |key|
          if actual.public_send(key) != expected[key]
            return true
          end
        end
        false
      end

      def different_array?(expected, actual, key, keys)
        if expected[key].size != actual.public_send(key).size
          return true
        end
        sorted_expected = expected[key].sort_by { |e| keys.map { |k| e[k] }.join('') }
        sorted_actual = actual.public_send(key).sort_by { |a| keys.map { |k| a.public_send(k) }.join('') }
        sorted_expected.zip(sorted_actual) do |e, a|
          if different_members?(e, a, keys)
            return true
          end
        end
        false
      end
    end
  end
end
