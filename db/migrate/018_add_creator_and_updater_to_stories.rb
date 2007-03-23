class AddCreatorAndUpdaterToStories < ActiveRecord::Migration
  def self.up
    add_column "stories", "creator_id", :integer
    add_column "stories", "updater_id", :integer
  end

  def self.down
    remove_column "stories", "creator_id"
    remove_column "stories", "updater_id"
  end
end
