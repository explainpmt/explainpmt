class Task < ActiveRecord::Base
  belongs_to :story
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :story_id
  
  scope :for_user, lambda{ |user| where("tasks.user_id = ?", user.id)}
  scope :complete, where(:complete => true)
  scope :incomplete, where(:complete => false)
  
  def assign_to!(new_owner)
    update_attribute(:user_id, new_owner.id)
  end

  def release_ownership!
    update_attribute(:user_id, nil)
  end

end
