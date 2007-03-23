class AddTeamToUser < ActiveRecord::Migration
  def self.up
    add_column "users", "team", :string
  end

  def self.down
    remove_column "users", "team"
  end
end
