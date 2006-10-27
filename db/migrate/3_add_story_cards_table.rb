class AddStoryCardsTable < ActiveRecord::Migration
  def self.up
    create_table :story_cards do |t|
      t.column :project_id, :integer
      t.column :scid, :integer
      t.column :user_id, :integer
      t.column :name, :string
      t.column :status, :string
    end
  end

  def self.down
    drop_table :story_cards
  end
end
