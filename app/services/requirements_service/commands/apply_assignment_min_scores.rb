module RequirementsService
  module Commands
    class ApplyAssignmentMinScores
      def initialize(context_module:, force: false)
        @context_module = context_module
        @completion_requirements = context_module.completion_requirements
        @force = force
        @course = context_module.course
        @settings = SettingsService.get_settings(object: :course, id: course.try(:id))
        @threshold_exists = !!settings['passing_threshold']
        @score_threshold = settings['passing_threshold'].to_f
        @threshold_overrides = settings['threshold_overrides']
      end

      def call
        return unless threshold_exists

        if force
          RequirementsService.strip_overrides(course) if threshold_overrides
        else
          return unless threshold_changes_needed?
        end

        run_command
      end

      private

      attr_reader :completion_requirements, :context_module, :course, :force, :score_threshold, :threshold_overrides, :settings, :threshold_exists

      def run_command
        if score_threshold.zero?
          reset_requirements
        else
          add_min_score_to_requirements
          finalize_update
        end
      end

      def reset_requirements
        RequirementsService.reset_requirements(context_module: context_module)
      end

      def finalize_update
        context_module.update_column(:completion_requirements, completion_requirements)
        context_module.touch
      end

      def threshold_changes_needed?
        return false unless score_threshold.positive?
        completion_requirements.any? do |req|
          is_submittable?(req) || (min_score_different_than_threshold?(req) && not_unit_exam?(req))
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
        ["must_submit", "must_contribute", "min_score"].none? { |type| type == requirement[:type] } ||
        unit_exam?(requirement)
      end
    
      def add_min_score_to_requirements
        completion_requirements.each do |requirement|
          next if skippable_requirement?(requirement)
          update_score(requirement)
        end
      end
    
      def update_score(requirement)
        requirement.merge!(type: 'min_score', min_score: score_threshold)
      end

      def unit_exam?(requirement)
        content_tag = ContentTag.find_by(id: requirement[:id])
        content_tag && RequirementsService.is_unit_exam?(content_tag: content_tag)
      end

      def not_unit_exam?(requirement)
        !unit_exam?(requirement)
      end
    end
  end
end
