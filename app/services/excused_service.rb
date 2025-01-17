module ExcusedService
  def self.bulk_excuse(assignment:, exclusions:)
    Commands::HandleExclusions.new(assignment: assignment, exclusions: exclusions).call
  end

  def self.bulk_unassign(assignment:, assignment_params:)
    Commands::HandleUnassigns.new(assignment: assignment, assignment_params: assignment_params).call
  end

  def self.student_names_ids(group)
    group.map {|obj| {id: obj.user_id, name: obj.user.name} }
  end

  def self.students_in_course(course)
    student_names_ids(course.student_enrollments.where(type: "StudentEnrollment"))
  end
  
  def self.excused_students(assignment)
    submissions = assignment ? assignment.excused_submissions : []
    student_names_ids(submissions)
  end

  def self.unassigned_students(assignment)
    return nil unless assignment&.id
    SettingsService.get_settings(
      object: :assignment,
      id: "#{assignment.id}"
    )['unassigned_students']
  end

  def self.formatted_unassigned_students(assignment)
    formatted = (unassigned_students(assignment) || "").split(",")
    formatted.map do |student_id|
      student = User.find(student_id)
      return nil unless student
      { id: student_id, name: student.name }
    end.compact
  end
end