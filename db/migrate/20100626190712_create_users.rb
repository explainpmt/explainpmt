class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :login
      t.string  :email
      t.string  :crypted_password
      t.string  :salt
      
      t.string  :persistence_token
      t.string  :single_access_token
      t.string  :perishable_token
      
      t.integer :login_count, :null => false, :default => 0
      t.integer :failed_login_count,  :null => false, :default => 0
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string  :current_login_ip
      t.string  :last_login_ip
      
      t.boolean :is_admin,  :null => false, :default => 0
      t.string  :team
      
      t.string  :first_name
      t.string  :last_name
      
      t.timestamps
    end
    
    add_index :users, :login, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :single_access_token
    add_index :users, :perishable_token
  end

  def self.down
    drop_table :users
  end
end
