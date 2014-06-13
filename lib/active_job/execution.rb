require 'active_support/rescuable'
require 'active_job/arguments'

module ActiveJob
  module Execution
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Rescuable
    end

    def execute
      run_callbacks :perform do
        perform *Arguments.deserialize(arguments)
      end
    rescue => exception
      rescue_with_handler(exception) || raise(exception)
    end

    def perform(*)
      raise NotImplementedError
    end
  end
end
