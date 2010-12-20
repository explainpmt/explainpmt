

class CreateInitialDatabase < ActiveRecord::Migration
  class User < ActiveRecord::Base; end

  def self.up
    create_table :iterations do |t|
      t.column :project_id, :integer
      t.column :start_date, :date
      t.column :length, :integer
      t.column :budget, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :milestones do |t|
      t.column :project_id, :integer
      t.column :date, :date
      t.column :name, :string
      t.column :description, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :projects do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :projects_users, :id => false do |t|
      t.column :user_id, :integer
      t.column :project_id, :integer
    end

    create_table :stories do |t|
      t.column :scid, :integer
      t.column :project_id, :integer
      t.column :iteration_id, :integer
      t.column :user_id, :integer
      t.column :title, :string
      t.column :points, :integer
      t.column :status, :integer
      t.column :priority, :integer
      t.column :risk, :integer
      t.column :description, :text
    end

    create_table :users do |t|
      t.column :username, :string
      t.column :password, :string
      t.column :email, :string
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :admin, :boolean
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    # Create the initial admin user
    # User.create :username => 'admin', :password => 'admin', :email => 'admin@example.com', :first_name => 'admin',
    #   :last_name => 'admin', :admin => true
  end

  def self.down
    drop_table :iterations
    drop_table :milestones
    drop_table :projects
    drop_table :projects_users
    drop_table :stories
    drop_table :users
  end
end