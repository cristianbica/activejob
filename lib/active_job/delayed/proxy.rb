module ActiveJob
  module Delayed
    class Proxy < BasicObject
      def initialize(target, options)
        @target = target.to_s
        @options = options
      end

      def method_missing(method_name, *args)
        queue_name_was = ActiveJob::Delayed::Worker.queue_name
        if options[:in]
          ActiveJob::Delayed::Worker.enqueue_in options.delete(:in), @target, method_name, args, options
        elsif options[:at]
          ActiveJob::Delayed::Worker.enqueue_at options.delete(:at), @target, method_name, args, options
        else
          ActiveJob::Delayed::Worker.enqueue, @target, method_name, args, options
        end
      end
    end
  end
end
