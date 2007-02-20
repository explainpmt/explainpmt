class Task < ActiveRecord::Base
  belongs_to :story
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => "story_id"
    
  def self.find_all_by_user_and_project(user_id, project_id)
    Task.find_by_sql ["SELECT * FROM tasks where user_id = ? AND story_id in (select id from stories where project_id = ? AND status not in (7,8))",user_id, project_id]
  end
  
  def self.find_all_by_user(user_id)
    Task.find_by_sql ["SELECT * FROM tasks where user_id = ? AND story_id in (select id from stories where status not in (7,8))",user_id]
  end
  
end
