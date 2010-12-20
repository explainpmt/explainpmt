class AddPlannedIterationsToProject < ActiveRecord::Migration
  def self.up
    add_column "projects", "planned_iterations", :integer
  end

  def self.down
    remove_column "projects", "planned_iterations"
  end
end
