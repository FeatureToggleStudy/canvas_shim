AssignmentsApiController.class_eval do
  def strongmind_update
    @assignment = @context.active_assignments.api_id(params[:id])
    handle_exclusions
    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  def strongmind_create
    instructure_create
    handle_exclusions
  end

  alias_method :instructure_create, :create
  alias_method :create, :strongmind_create

  private

  def handle_exclusions
    if @assignment && params['assignment'] && params['assignment']['excluded_students']
      begin
        Assignment.transaction do
          params['assignment']['excluded_students'].each do |student|
            @assignment.toggle_exclusion(student['id'].to_i, true)
          end
          unexcuse_assignments(params['assignment']['excluded_students'])
        end
      rescue StandardError => exception
        Raven.capture_exception(exception)
      end
    end
  end

  def unexcuse_assignments(arr)
    student_ids = arr.map { |student| student['id'] }
    excused = @assignment.excused_submissions
    excused = excused.where("user_id NOT IN (?)", student_ids) if student_ids.any?
    excused.each do |sub|
      @assignment.toggle_exclusion(sub.user_id, false)
    end
  end
end