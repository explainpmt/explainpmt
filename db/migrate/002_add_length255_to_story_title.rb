class AddLength255ToStoryTitle < ActiveRecord::Migration
  def self.up
    change_column :stories, :title, :string, :length => 255
  end

  def self.down
    change_column :stories, :title, :string
  end
end
