module DomainEvents
  module Events
    class GradedOut
      def initialize(args)
        @listeners = args[:listeners]
        @message   = args[:message]
      end

      def emit
        return unless should_trigger?
        listeners.each { |listener| listener.call(message: message) }
      end

      private

      attr_accessor :listeners, :message

      def should_trigger?
        return unless message[:noun] == 'student_enrollment'
        return unless message[:data][:state] == 'completed'
        true
      end
    end
  end
end
