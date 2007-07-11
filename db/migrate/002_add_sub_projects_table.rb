


class AddSubProjectsTable < ActiveRecord::Migration
  def self.up
    create_table "sub_projects" do |t|
      t.column "project_id", :integer
      t.column "name", :string
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
  end

  def self.down
    drop_table "sub_projects"
  end
end
