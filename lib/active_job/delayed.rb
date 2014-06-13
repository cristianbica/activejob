module ActiveJob
  module Delayed
    extend  ActiveSupport::Concern

    module ClassMethods
      def delay(options={})
        ActiveJob::Delayed::Proxy.new(self, options)
      end

      def delay_for(interval, options={})
        delay(options.merge(in: interval))
      end

      def delay_until(timestamp, options={})
        delay(options.merge(at: timestamp))
      end
    end

  end
end
