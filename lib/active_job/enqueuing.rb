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
        new.tap do |job|
          job.run_callbacks :enqueue do
            queue_adapter.enqueue \
              'job_class' => job.class,
              'job_id'    => job.job_id,
              'queue'     => job.queue,
              'arguments' => Arguments.serialize(args)
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
        new.tap do |job|
          job.enqueued_at = timestamp

          job.run_callbacks :enqueue do
            queue_adapter.enqueue_at timestamp.to_f, \
              'job_class' => job.class,
              'job_id'    => job.job_id,
              'queue'     => job.queue,
              'arguments' => Arguments.serialize(args)
          end
        end
      end
    end

    included do
      attr_accessor :arguments
      attr_accessor :enqueued_at
    end

    def initialize(options={})
      @arguments = options['arguments']
      @queue     = options['queue'] if options['queue']
      @job_id    = options['job_id']
    end

    def retry_now
      self.class.enqueue *arguments
    end

    def retry_in(interval)
      self.class.enqueue_in interval, *arguments
    end

    def retry_at(timestamp)
      self.class.enqueue_at timestamp, *arguments
    end
  end
end
