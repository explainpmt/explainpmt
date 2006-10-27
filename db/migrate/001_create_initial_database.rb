class CreateInitialDatabase < ActiveRecord::Migration
  def self.up
    create_table "iterations", :force => true do |t|
      t.column "project_id", :integer, :default => 0, :null => false
      t.column "start_date", :date
      t.column "length", :integer, :default => 14
      t.column "budget", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    create_table "milestones", :force => true do |t|
      t.column "project_id", :integer, :default => 0, :null => false
      t.column "date", :date
      t.column "name", :string
      t.column "description", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    create_table "projects", :force => true do |t|
      t.column "name", :string
      t.column "description", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    create_table "projects_users", :id => false, :force => true do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "project_id", :integer, :default => 0, :null => false
    end

    create_table "stories", :force => true do |t|
      t.column "scid", :integer, :default => 0, :null => false
      t.column "project_id", :integer, :default => 0, :null => false
      t.column "iteration_id", :integer
      t.column "user_id", :integer
      t.column "title", :string
      t.column "points", :integer
      t.column "status", :integer
      t.column "priority", :integer
      t.column "risk", :integer
      t.column "description", :text
    end

    create_table "users", :force => true do |t|
      t.column "username", :string
      t.column "password", :string
      t.column "email", :string
      t.column "first_name", :string
      t.column "last_name", :string
      t.column "admin", :boolean, :default => false
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end


  end

  def self.down
    drop_table "iterations"
    drop_table "milestones"
    drop_table "projects"
    drop_table "projects_users"
    drop_table "stories"
    drop_table "users"
  end
end
