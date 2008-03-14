class AddReleaseToStory < ActiveRecord::Migration
  def self.up
    add_column "stories", "release_id", :integer
  end

  def self.down
    remove_column "stories", "release_id", :integer
  end
end
