class AddReleases < ActiveRecord::Migration
  def self.up
    puts 'Adding Releases Table'
    create_table :releases do |t|
      t.column :number, :integer
      t.column :name, :string
      t.column :goal, :text
      t.column :release_date, :date
      t.column :project_id, :integer
    end
    add_index :releases, :project_id

    puts 'Adding Iteration->Release Link'
    add_column :iterations, :release_id, :integer
    add_index :iterations, :release_id
  end

  def self.down
    puts 'Removing Releases Table'
    remove_column :iterations, :release_id
    drop_table :releases
  end
end
