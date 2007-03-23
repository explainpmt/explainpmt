class AddCreateAndUpdateAtToStories < ActiveRecord::Migration
  def self.up
    add_column "stories", "created_at", :datetime
    add_column "stories", "updated_at", :datetime
  end

  def self.down
    remove_column "stories", "created_at"
    remvoe_column "stories", "updated_at"
  end
end