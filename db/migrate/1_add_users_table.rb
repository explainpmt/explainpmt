class AddUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :admin, :boolean
      t.column :login, :string
      t.column :email, :string
      t.column :password, :string
      t.column :name, :string
    end
    first_admin = User.new
    first_admin.admin = true
    first_admin.login = 'admin'
    first_admin.email = 'admin@example.com'
    first_admin.password = 'admin'
    first_admin.name = 'Admin User'
    first_admin.save
  end

  def self.down
    drop_table :users
  end
end
