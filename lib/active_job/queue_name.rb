module ActiveJob
  module QueueName
    extend ActiveSupport::Concern

    def queue
      @queue || class.queue_name
    end

    def queue=(part_name)
      @queue = "#{class.queue_base_name}_#{part_name}"
    end

    module ClassMethods
      mattr_accessor(:queue_base_name) { "active_jobs" }

      def queue_as(part_name)
        self.queue_name = "#{queue_base_name}_#{part_name}"
      end
    end

    included do
      class_attribute :queue_name
      self.queue_name = queue_base_name
    end
  end
end
