module ActiveJob
  module Delayed
    class Proxy < BasicObject
      def initialize(target, options)
        @target = target.to_s
        @options = options
      end

      def method_missing(method_name, *args)
        queue_name_was = ActiveJob::Delayed::Worker.queue_name
        begin
          ActiveJob::Delayed::Worker.queue_as = options :queue
          if options[:in]
            ActiveJob::Delayed::Worker.enqueue_in options.delete(:in), @target, method_name, args
          elsif options[:at]
            ActiveJob::Delayed::Worker.enqueue_at options.delete(:at), @target, method_name, args
          else
            ActiveJob::Delayed::Worker.enqueue, @target, method_name, args
          end
        ensure
          ActiveJob::Delayed::Worker.queue_name = queue_name_was
        end
      end
    end
  end
end
