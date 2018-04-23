module PipelineService
  module Endpoints
    class Pipeline
      def initialize(message:, args: {})
        @message     = message
        @endpoint    = ENV['PIPELINE_ENDPOINT']
        @username    = ENV['PIPELINE_USER_NAME']
        @password    = ENV['PIPELINE_PASSWORD']
        @publisher   = args[:publisher] || PipelinePublisher
        @http_client = args[:http_client] || PipelinePublisher::MessagesApi.new
        @message_builder_class = args[:message_builder_class] || MessageBuilder
      end

      def call
        raise 'Missing config' if missing_config?
        configure
        post
      end

      private

      attr_reader :message, :http_client, :endpoint, :username, :password, :publisher, :message, :message_builder_class

      def missing_config?
        [endpoint, username, password].any?(&:nil?)
      end

      def post
        http_client.messages_post(
          message_builder_class.new(message).build
        )
      end

      def configure
        publisher.configure do |config|
          config.host     = endpoint
          config.username = username
          config.password = password
        end
      end
    end
  end
end
