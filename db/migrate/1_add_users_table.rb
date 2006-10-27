class AddUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :admin, :boolean
      t.column :login, :string
      t.column :email, :string
      t.column :password, :string
      t.column :name, :string
    end
  end

  def self.down
    drop_table :users
  end
end
