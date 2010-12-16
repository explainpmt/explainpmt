class Release < ActiveRecord::Base
  
  belongs_to :project
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id
  
  has_many :stories, :dependent => :nullify do
    def not_estimated_and_not_cancelled
      self.select { |s|
        s.status != Story::Status::Cancelled and
        s.points.nil?
      }
    end

    def uncompleted
      self.select { |s|
        s.status != Story::Status::Complete and
        s.status != Story::Status::Accepted and
        s.status != Story::Status::Cancelled }
    end

    def completed
      self.select { |s|
        s.status == Story::Status::Complete or
        s.status == Story::Status::Accepted  }
    end

    def points_completed
      self.completed.inject(0) {|total, completed_story| total + completed_story.points.to_f}
    end
    
    def points_not_completed
      self.uncompleted.inject(0) {|total, uncompleted_story| total + uncompleted_story.points.to_f}
    end
  end
  
end
