require 'resque'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/array/access'

begin
  require 'resque-scheduler'
rescue LoadError
  begin
    require 'resque_scheduler'
  rescue LoadError
    $stderr.puts 'The ActiveJob resque adapter requires resque-scheduler. Please add it to your Gemfile and run bundle install'
    raise e
  end
end

module ActiveJob
  module QueueAdapters
    class ResqueAdapter
      class << self
        def enqueue(job, *args)
          Resque.enqueue_to job.queue_name, JobWrapper, job.name, *args
        end

        def enqueue_at(job, timestamp, *args)
          Resque.enqueue_at_with_queue job.queue_name, timestamp, JobWrapper, job.name, *args
        end
      end

      class JobWrapper
        class << self
          def perform(job_name, *args)
            job_name.constantize.new.execute *args
          end
        end
      end
    end
  end
end
