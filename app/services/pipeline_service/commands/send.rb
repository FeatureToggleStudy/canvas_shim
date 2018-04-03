module PipelineService
  module Commands


    class Send
      attr_reader :message, :persisted_message

      MESSAGE_NAME = 'enrollment'
      SOURCE       = 'canvas'

      def initialize(args)
        @host              = ENV['PIPELINE_ENDPOINT']
        @username          = ENV['PIPELINE_USER_NAME']
        @password          = ENV['PIPELINE_PASSWORD']
        @domain_name       = ENV['CANVAS_DOMAIN']


        raise 'Missing environment variables' if config_missing?

        @api_instance    = args[:message_api] || PipelinePublisher::MessagesApi.new
        @publisher       = args[:publisher] || PipelinePublisher
        @message_builder = args[:message_builder] || publisher::Message
        @serializer      = args[:serializer] || Serializer.new
        @enrollment      = args[:enrollment]
        @user            = args[:user]
        @queue           = args[:queue] || false
        @message_type    = args[:message_type] || :upsert
      end

      def call
        configure
        @payload = serialize_enrollment
        @message = build_pipeline_message
        @job     = build_job
        post
        persist
        self
      end

      private

      attr_reader :payload, :enrollment, :username, :password,
        :user, :api_instance, :payload, :publisher, :host,
        :serializer, :domain_name, :message_builder, :queue, :job,
        :message_type

      def persist
        @persisted_message = HashWithIndifferentAccess.new(
          JSON.parse(message.to_json)
        ).delete_blank.to_json
        
        HTTParty.post(
          "https://lrs.strongmind.com/pipeline-watcher-staging",
          body: persisted_message
        )
      end

      def config_missing?
        [@host, @username, @password].any?(&:nil?)
      end

      def build_job
        Jobs::PostEnrollmentJob.new(
          api_instance: api_instance,
          message: message
        )
      end

      def configure
        publisher.configure do |config|
          config.host     = host
          config.username = username
          config.password = password
        end
      end

      def post
        return job.perform unless queue
        Delayed::Job.enqueue job
      end

      def serialize_enrollment
        serializer.enrollment_json(
          enrollment,
          user,
          {}
        )
      end

      def build_pipeline_message
        message_builder.new(
          noun: MESSAGE_NAME,
          meta: {
            source: SOURCE,
            domain_name: domain_name
          },
          identifiers: { id: enrollment.id },
          data: message_type == :removed ? {} : payload
        )
      end
    end
  end
end
