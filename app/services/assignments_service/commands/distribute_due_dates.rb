module AssignmentsService
  module Commands
    class DistributeDueDates
      def initialize(args)
        @args = args
        @course = args[:course]
        @assignment_query = Queries::AssignmentsWithDueDates.new(course: @course)
      end

      def call
        return if multiple_imports?
        course_assignments = assignments
        clear_due_dates(course_assignments)
        return unless SettingsService.get_settings(object: :school, id: 1)['auto_due_dates'] == 'on'
        return unless course.start_at && course.end_at
        offset = 0
        scheduler.course_dates.each do |date, count|

          if count.zero?
            offset += 1
            next
          else
            offset = 0
          end

          update_assignments(course_assignments.slice!(offset..count - 1), date)
        end

        claim_import
      end

      private

      attr_reader :course, :assignments_per_day

      def scheduler
        @scheduler ||= Scheduler.new(@args.merge(assignment_count: assignments.count))
      end

      def update_assignments(assignments_for_day, date)
        assignments_for_day.each do |assignment|
          next if assignment.nil?
          assignment.update(due_at: date)
        end
      end

      def assignments
        @assignment_query.query
      end

      def clear_due_dates(course_assignments)
        course_assignments.each do |asst|
          asst.update(due_at: nil)
        end
      end

      def claim_import
        if @course.content_migrations.where(workflow_state: "imported").one?
          SettingsService.update_settings(
            object: 'course',
            id: @course.id,
            setting: 'imported_content',
            value: true
          )
        end
      end

      def multiple_imports?
        SettingsService.get_settings(object: :course, id: @course.id)['imported_content']
      end
    end
  end
end
