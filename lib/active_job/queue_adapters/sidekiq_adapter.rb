require 'sidekiq'

module ActiveJob
  module QueueAdapters
    class SidekiqAdapter
      class << self
        def enqueue(options)
          #Sidekiq::Client does not support symbols as keys
          Sidekiq::Client.push \
            'class' => JobWrapper,
            'queue' => options['queue'],
            'args'  => options,
            'retry' => true
        end

        def enqueue_at(timestamp, options)
          Sidekiq::Client.push \
            'class' => JobWrapper,
            'queue' => options['queue'],
            'args'  => options,
            'retry' => true,
            'at'    => timestamp
        end
      end

      class JobWrapper
        include Sidekiq::Worker

        def perform(options)
          options['job_class'].constantize.new(options).execute *args
        end
      end
    end
  end
end
