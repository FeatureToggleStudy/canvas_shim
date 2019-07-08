module PipelineService
  module V2
    module Nouns
      class Submission < Base

        include Api
        include Api::V1::Submission
        include Rails.application.routes.url_helpers
        include PipelineService::Serializers::BaseMethods
        Rails.application.routes.default_url_options[:host] = ENV['CANVAS_DOMAIN']

        def initialize(object:)
          @submission = object.ar_model
        end

        def params
          { includes: ['submission_history'] }
        end

        def call
          load_attachments
          submission_json(
            @submission,
            @submission.assignment,
            GradesService::Account.account_admin,
            {},
            nil,
            ['submission_history']
          )
        end

        def self.additional_identifier_fields
          [
            Identifier.new(Proc.new {|ar_model| [:assignment_id, ar_model.assignment.id]}),
            Identifier.new(Proc.new {|ar_model| [:course_id, ar_model.assignment.course.id]})
          ]
        end
  
        def load_attachments
          submissions = [@submission]
          ::Submission.bulk_load_versioned_attachments(submissions)
          attachments = submissions.flat_map &:versioned_attachments
          ActiveRecord::Associations::Preloader.new.preload(
            attachments,
            [:canvadoc, :crocodoc_document]
          )
          Version.preload_version_number(submissions)
        end
      end
    end
  end
end
