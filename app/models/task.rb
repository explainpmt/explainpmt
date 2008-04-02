class Task < ActiveRecord::Base
  belongs_to :story
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :story_id

  def assign_to(new_owner)
    self.owner = new_owner
    save
  end

  def release_ownership
    self.owner = nil
    save
  end

end
