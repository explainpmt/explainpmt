class AddStoryCardsTable < ActiveRecord::Migration
  def self.up
    create_table :story_cards do |t|
      t.column :scid, :integer
      t.column :project_id, :integer
      t.column :user_id, :integer
      t.column :name, :string
      t.column :points, :integer
      t.column :status, :string
      t.column :priority, :integer
      t.column :risk, :integer
      t.column :description, :text
    end
  end

  def self.down
    drop_table :story_cards
  end
end
