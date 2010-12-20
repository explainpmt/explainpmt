class RenameAuditsColumn < ActiveRecord::Migration
  def self.up
    rename_column "audits", "object_id", "audited_object_id"
  end

  def self.down
    rename_column "audits", "audited_object_id", "object_id"
  end
end
