class CreateAuditsTable < ActiveRecord::Migration
  def self.up
    create_table :audits do |t|
      t.column "object_id", :integer
      t.column "object", :string
      t.column "project_id", :integer
      t.column "created_at", :datetime
      t.column "before", :text
      t.column "after", :text
      t.column "user", :string
    end
  end

  def self.down
    drop_table :audits
  end
end
