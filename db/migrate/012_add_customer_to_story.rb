class AddCustomerToStory < ActiveRecord::Migration
  def self.up
      add_column "stories", "customer", :string
  end

  def self.down
      remove_column "stories", "customer"
  end
end
