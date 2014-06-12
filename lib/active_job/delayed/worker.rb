module ActiveJob
  module Delayed
    class Worker < ActiveJob::Base
      def perform(target, method_name, args)
        target.constantize.__send__ method_name, args
      end
    end
  end
end
