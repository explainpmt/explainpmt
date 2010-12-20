class AddSubProjectIdToStories < ActiveRecord::Migration
  def self.up
    add_column "stories", "sub_project_id", :integer
  end

  def self.down
    remove_column "stories", "sub_project_id"
  end
end
