class AddColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column  :users, :first_name,  :string
    add_column  :users, :last_name, :string
  end

  def self.down
    remove_column :users, :first_name,  :last_name
  end
end
