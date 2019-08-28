module UnitsService
  module Queries
    class GetSubmissions
      def initialize(course:, student:)
        @student = student
        @course = course
      end

      def query
        result = {}
        units.each do |unit, items|
          items.each do |item|
            subs = item.content.try(:submissions) ||
                  item.content.try(:assignment).submissions
            subs
              .where(user_id: @student.id).each do |submission|
                result[unit] ||= []
                if submission.excused?
                  submission = submission.dup
                  submission.score = nil
                end
                result[unit] << submission
              end
          end
        end

        result
      end

      def units
        GetItems.new(course: @course).query
      end
    end
  end
end
