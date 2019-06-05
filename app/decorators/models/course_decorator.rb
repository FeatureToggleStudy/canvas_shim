Course.class_eval do
  has_many :active_students, -> { where("enrollments.workflow_state NOT IN ('rejected', 'deleted', 'inactive', 'invited') AND enrollments.type = 'StudentEnrollment'").preload(:user) }, class_name: 'Enrollment'

  after_commit -> { PipelineService.publish(self) }
  after_create :set_default_course_threshold, if: :account_threshold_set?

  def force_min_scores
    context_modules.each(&:force_min_score_to_requirements)
  end

  def no_active_students?
    active_students.count.zero?
  end

  private
  def set_default_course_threshold
    SettingsService.update_settings(
      object: 'school',
      id: 1,
      setting: 'score_threshold',
      value: account_threshold
    )
  end

  def account_threshold
    SettingsService.get_settings(object: :school, id: 1)['score_threshold'].to_f
  end

  def account_threshold_set?
    account_threshold.positive?
  end
end
