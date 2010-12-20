class CreateInitiativesTable < ActiveRecord::Migration
  def self.up
    create_table :initiatives do |t|
      t.column :name, :string
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :customer, :string
      t.column :product_owner, :string
      t.column :project_id, :integer
    end
  end

  def self.down
    drop_table :initiatives
  end
end
