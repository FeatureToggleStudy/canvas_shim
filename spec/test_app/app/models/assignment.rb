class Assignment < ActiveRecord::Base
  has_many :submissions
  belongs_to :course
  def due_date
    due_at
  end
end
