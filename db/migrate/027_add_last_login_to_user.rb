class AddLastLoginToUser < ActiveRecord::Migration
  def self.up
    add_column "users", "last_login", :datetime
  end

  def self.down
    drop_column "users", "last_login"
  end
end
