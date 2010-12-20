class AddTempPassword < ActiveRecord::Migration
  def self.up
    add_column :users, :temp_password, :string
  end

  def self.down
    remove_column :users, :temp_password
  end
end
