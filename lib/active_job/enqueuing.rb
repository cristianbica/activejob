require 'active_job/arguments'

module ActiveJob
  module Enqueuing
    extend ActiveSupport::Concern

    module ClassMethods
      # Push a job onto the queue.  The arguments must be legal JSON types
      # (string, int, float, nil, true, false, hash or array) or
      # ActiveModel::GlobalIdentication instances.  Arbitrary Ruby objects
      # are not supported.
      #
      # Returns an instance of the job class queued with args available in
      # Job#arguments.
      def enqueue(*args)
        job_or_instantiate(*args).tap do |job|
          job.run_callbacks :enqueue do
            queue_adapter.enqueue job.to_enqueueable_hash
          end
        end
      end

      # Enqueue a job to be performed at +interval+ from now.
      #
      #   enqueue_in(1.week, "mike")
      #
      # Returns an instance of the job class queued with args available in
      # Job#arguments and the timestamp in Job#enqueue_at.
      def enqueue_in(interval, *args)
        enqueue_at interval.seconds.from_now, *args
      end

      # Enqueue a job to be performed at an explicit point in time.
      #
      #   enqueue_at(Date.tomorrow.midnight, "mike")
      #
      # Returns an instance of the job class queued with args available in
      # Job#arguments and the timestamp in Job#enqueue_at.
      def enqueue_at(timestamp, *args)
        job_or_instantiate(*args).tap do |job|
          job.enqueued_at = timestamp

          job.run_callbacks :enqueue do
            queue_adapter.enqueue_at timestamp.to_f, job.to_enqueueable_hash
          end
        end
      end

      protected
        def job_or_instantiate(*args)
          args.first.is_a?(self) ? args.first : new('arguments' => args)
        end
    end

    included do
      attr_accessor :arguments
      attr_accessor :enqueued_at
      attr_reader   :job_id
      attr_reader   :queue
    end

    def initialize(options = {})
      @options = options
      @arguments = options['arguments']
      @job_id    = options['job_id'] || SecureRandom.uuid
      self.queue = options['queue']
    end

    def queue=(part_name)
      @queue = [self.class.queue_base_name, part_name].compact.join("_")
    end

    def retry_now
      self.class.enqueue self
    end

    def retry_in(interval)
      self.class.enqueue_in interval, self
    end

    def retry_at(timestamp)
      self.class.enqueue_at timestamp, self
    end

    def to_enqueueable_hash
      {
        'job_class' => self.class.name,
        'job_id'    => job_id,
        'queue'     => queue,
        'arguments' => Arguments.serialize(arguments)
      }
    end
  end
end
