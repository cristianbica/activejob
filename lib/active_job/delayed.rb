module ActiveJob
  module Delayed
    extend  ActiveSupport::Concern

    module ClassMethods
      def delay(options={})
        options[:queue] ||= :default
        ActiveJob::Delayed::Proxy.new(self, options)
      end

      def delay_for(interval, options={})
        options[:queue] ||= :default
        options[:in]      = interval
        ActiveJob::Delayed::Proxy.new(self, options)
      end

      def delay_until(timestamp, options={})
        options[:queue] ||= :default
        options[:at]      = timestamp
        ActiveJob::Delayed::Proxy.new(self, options)
      end
    end

  end
end
