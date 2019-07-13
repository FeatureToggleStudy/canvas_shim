Submission.class_eval do
  after_commit :send_max_attempts_alert

  def send_max_attempts_alert
    return unless student_locked?
    teachers_to_alert.each do |teacher|
      AlertsService::Client.create(
        :max_attempts_reached,
        teacher_id: teacher.id,
        student_id: user.id,
        assignment_id: assignment.id
      )
    end
  end

  def student_locked?
    return unless used_attempts && max_attempts
    return unless used_attempts >= max_attempts

    content_tag = ContentTag.find_by(content_id: assignment.id, content_type: 'Assignment')
    return unless content_tag
    context_module = content_tag.context_module
    return unless context_module
    requirement = context_module.completion_requirements.find { |req| req[:id] == content_tag.id }
    return unless requirement
    return unless requirement[:min_score]
    score < requirement[:min_score]
  end

  def teachers_to_alert
    assignment.course.teacher_enrollments.map { |enrollement| enrollement.user }
  end

  def max_attempts
    migration_id = assignment.try(:migration_id)
    return unless migration_id

    assignment_settings = SettingsService.get_settings(id: migration_id.to_s, object: 'assignment')
    student_assignment_settings = SettingsService.get_settings(
      id: {
        assignment_id: assignment.id,
        student_id: user.id
      },
      object: 'student_assignment'
    )

    if assignment.title.downcase == 'final exam'
      1
    elsif assignment_settings and assignment_settings['max_attempts']
      assignment_settings['max_attempts'].to_i
    elsif student_assignment_settings and student_assignment_settings['max_attempts']
      student_assignment_settings['max_attempts'].to_i
    end
  end

  def used_attempts
    versions = self.try(:versions)
    return unless versions
    versions.map.select { |ver| YAML.load(ver.yaml)['grader_id'] && YAML.load(ver.yaml)['grader_id'] < 0 }.map {|ver| YAML.load(ver.yaml)['attempt'] || 0}.uniq.sort.last
  end
end
