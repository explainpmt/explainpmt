class AddNameToIteraion < ActiveRecord::Migration
  def self.up
  add_column "iterations", "name", :string
  end

  def self.down
  end
end
