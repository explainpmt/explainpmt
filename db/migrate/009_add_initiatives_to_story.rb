class AddInitiativesToStory < ActiveRecord::Migration
  def self.up
    add_column "stories", "initiative_id", :integer
  end

  def self.down
    remove_column "stories", "initiative_id"
  end
end
