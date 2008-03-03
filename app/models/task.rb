class Task < ActiveRecord::Base
  belongs_to :story
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :story_id
end
