class ChangeAcceptanceTableColumnsToText < ActiveRecord::Migration
  def self.up
    change_column "acceptancetests", "pre_condition", :text
    change_column "acceptancetests", "post_condition", :text
    change_column "acceptancetests", "expected_result", :text
    change_column "acceptancetests", "description", :text
  end

  def self.down
    change_column "acceptancetests", "pre_condition", :string
    change_column "acceptancetests", "post_condition", :string
    change_column "acceptancetests", "expected_result", :string
    change_column "acceptancetests", "description", :string
  end
end
