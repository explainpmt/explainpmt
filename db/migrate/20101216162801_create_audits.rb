class CreateAudits < ActiveRecord::Migration
  def self.up
    create_table :audits do |t|
      t.column :auditable_id, :integer
      t.column :auditable_type, :string
      t.column :user_id, :integer
      t.column :admin_id, :integer
      t.column :action, :string
      t.column :auditable_changes, :text
      t.column :created_at, :datetime
      t.timestamps
    end
    
    add_index :audits, [:auditable_type, :auditable_id], :name => 'auditable_index'
    add_index :audits, :created_at
  end

  def self.down
    drop_table :audits
  end
end
