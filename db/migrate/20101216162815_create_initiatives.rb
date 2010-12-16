class CreateInitiatives < ActiveRecord::Migration
  def self.up
    create_table :initiatives do |t|
      t.string  :name
      t.date    :start_date
      t.date    :end_date
      t.string  :customer
      t.string  :product_owner
      t.integer :project_id
      t.timestamps
    end
    
    add_index :initiatives, [:project_id, :name], :unique => true
    add_index :initiatives, [:start_date, :end_date]
  end

  def self.down
    drop_table :initiatives
  end
end
