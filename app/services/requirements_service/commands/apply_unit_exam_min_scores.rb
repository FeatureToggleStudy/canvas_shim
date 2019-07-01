module RequirementsService
  module Commands
    class ApplyUnitExamMinScores
      def initialize(context_module:, force: false)
        @context_module = context_module
        @completion_requirements = context_module.completion_requirements
        @force = force
        @course = context_module.course
        @settings = SettingsService.get_settings(object: :course, id: course.try(:id))
        @score_threshold = settings['passing_exam_threshold'].to_f
        @threshold_overrides = settings['threshold_overrides']
      end

      def call
        return unless RequirementsService.get_course_exam_passing_threshold?(course)

        if force
          RequirementsService.strip_overrides(course) if threshold_overrides
        else
          return unless threshold_changes_needed?
        end

        run_command if threshold_set_or_positive?
      end

      private

      attr_reader :completion_requirements, :context_module, :course, :force, :score_threshold, :threshold_overrides, :settings

      def run_command
        add_min_score_to_requirements
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end

      def threshold_changes_needed?
        return false unless score_threshold.positive?
        completion_requirements.any? do |req|
          unit_exam?(req) && (is_submittable?(req) || min_score_different_than_threshold?(req))
        end
      end

      def is_submittable?(req)
        ["must_submit", "must_contribute"].include?(req[:type])
      end

      def min_score_different_than_threshold?(req)
        (req[:min_score] && req[:min_score] != score_threshold)
      end
    
      def has_threshold_override?(requirement)
        threshold_overrides.split(",").map(&:to_i).include?(requirement[:id]) if threshold_overrides
      end

      def skippable_requirement?(requirement)
        has_threshold_override?(requirement) ||
        not_unit_exam?(requirement)
      end
    
      def add_min_score_to_requirements
        completion_requirements.each do |requirement|
          next if skippable_requirement?(requirement)
          update_score(requirement)
        end
      end
    
      def update_score(requirement, unit_exam = false)
        requirement.merge!(type: 'min_score', min_score: score_threshold)
      end

      def unit_exam?(requirement)
        content_tag = ContentTag.find_by(id: requirement[:id])
        content_tag && RequirementsService.is_unit_exam?(content_tag: content_tag)
      end

      def not_unit_exam?(requirement)
        !unit_exam?(requirement)
      end

      def threshold_set_or_positive?
        settings['passing_exam_threshold'] || score_threshold.positive?
      end
    end
  end
end