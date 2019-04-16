module SettingsService
  class RepositoryBase
    include Singleton

    def initialize
      raise "missing canvas domain!" if SettingsService.canvas_domain.nil?
      @secret_key = ENV['S3_ACCESS_KEY']
      @id_key = ENV['S3_ACCESS_KEY_ID']
      Aws.config.update(
        region: 'us-west-2',
        credentials: creds
      )
    end

    def creds
      Aws::Credentials.new(@id_key, @secret_key)
    end

    class << self
      extend Forwardable
      def_delegators :instance, :create_table, :get, :put
    end

    def create_table(name:)
      begin
        dynamodb.create_table(table_params(name)).successful?
      rescue
      end
    end
    
    def dynamodb
      @dynamodb || Aws::DynamoDB::Client.new
    end
  end
end