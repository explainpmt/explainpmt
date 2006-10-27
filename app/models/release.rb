class Release < ActiveRecord::Base
  has_many :iterations
  belongs_to :project
  validates_uniqueness_of :release_date, :scope => 'project_id'
end
