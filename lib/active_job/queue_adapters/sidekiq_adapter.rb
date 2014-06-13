require 'sidekiq'

module ActiveJob
  module QueueAdapters
    class SidekiqAdapter
      class << self
        def enqueue(job)
          #Sidekiq::Client does not support symbols as keys
          Sidekiq::Client.push \
            'class' => JobWrapper,
            'queue' => job['queue'],
            'args'  => [ job ],
            'retry' => true
        end

        def enqueue_at(job, timestamp, *args)
          Sidekiq::Client.push \
            'class' => JobWrapper,
            'queue' => job['queue'],
            'args'  => [ job ],
            'retry' => true,
            'at'    => timestamp
        end
      end

      class JobWrapper
        include Sidekiq::Worker

        def perform(job)
          job['job_class'].constantize.new(job).execute
        end
      end
    end
  end
end
