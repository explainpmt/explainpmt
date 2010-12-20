class UpgradeDatabase < ActiveRecord::Migration
  def self.up
    # rename for authlogic
    rename_column :users, :username,  :login
    rename_column :users, :last_login,  :last_login_at
    rename_column :users, :password,  :crypted_password
    
    remove_column :users, :temp_password
    
    add_column  :users, :persistence_token, :string
    add_column  :users, :single_access_token, :string
    add_column  :users, :perishable_token,  :string
    add_column  :users, :login_count, :integer, :null => false, :default => 0
    add_column  :users, :failed_login_count,  :integer, :null => false, :default => 0
    add_column  :users, :current_login_at,  :datetime
    
    add_index :users, :login
    add_index :users, :email
    add_index :users, :single_access_token
    add_index :users, :perishable_token
    
    remove_index  :audits,  [:object, :audited_object_id]
    rename_column :audits,  :audited_object_id, :auditable_id
    rename_column :audits,  :object,  :auditable_type
    add_column    :audits,  :user_id, :integer
    add_column    :audits,  :action,  :string
    add_column    :audits,  :auditable_changes, :text
    
    add_index :audits,  [:auditable_type, :auditable_id], :name => 'auditable_index'
    add_index :audits,  :user_id
    add_index :audits,  :project_id
    add_index :audits,  :created_at
    
    #### REINSERT AUDITS...
    
    Audit.reset_column_information
    
    Audit.all.each do |audit|
      next unless audit.before && audit.after
      before_old = audit.before.split("\n")
      before_new = {}
      before_old.each do |c|
        b = c.match(/(.+)\[(.+)\]/).to_a
        before_new[b[1]] = b[2]
      end
      after_old = audit.after.split("\n")
      after_new = {}
      after_old.each do |c|
        b = c.match(/(.+)\[(.+)\]/).to_a
        after_new[b[1]] = b[2]
      end
      changes = {}
      before_new.keys.each do |k|
        changes[k] = [before_new[k], after_new[k]]
      end
      audit.auditable_changes = YAML.dump(changes)
      audit.save
    end
    
    remove_column :audits,  :before,  :after
    
    rename_table  :acceptancetests, :acceptance_tests
    add_index :acceptance_tests,  :project_id
    add_index :acceptance_tests,  :story_id
    
    remove_index  :initiatives, :project_id
    add_index :initiatives, [:project_id, :name], :unique => true
    add_index :initiatives, [:start_date, :end_date]
    
    remove_index  :iterations,  :project_id
    add_index :iterations,  [:project_id, :name], :unique => true
    
    add_index :stories, :release_id
  end

  def self.down
    rename_column :users, :login, :username
    rename_column :users, :last_login_at, :last_login
    rename_column :users, :crypted_password,  :password
    
    add_column  :users, :temp_password, :string
    
    remove_column :users, :persistence_token, :single_access_token, :perishable_token, :login_count, :failed_login_count, :current_login_at
    
    remove_index  :users, :login
    remove_index  :users, :email
    
    remove_index  :audits,  :name => "auditable_index"
    rename_column :audits,  :auditable_id, :audited_object_id
    rename_column :audits,  :auditable_type,  :object
    add_index     :audits,  [:object, :audited_object_id]
    remove_column :audits,  :user_id, :action
    add_column    :audits,  :before,  :string
    add_column    :audits,  :after, :string
    
    remove_index  :audits,  :project_id
    remove_index  :audits,  :created_at
    
    ## REINSERT AUDITS...
    
    Audit.reset_column_information
    
    Audit.all.each do |audit|
      c = audit.auditable_changes
      b, a = [], []
      c.each do |k,v|
        b << "#{key}[#{v.first}]"
        a << "#{key}[#{v.last}]"
      end
      audit.before = b.join("\n")
      audit.after = a.join("\n")
      audit.save
    end
    
    remove_column :audits,  :auditable_changes
    
    rename_table  :acceptance_tests,  :acceptancetests
    remove_index  :acceptancetests, :name => "index_acceptance_tests_on_project_id"
    remove_index  :acceptancetests, :name => "index_acceptance_tests_on_story_id"
    
    remove_index  :initiatives, [:start_date, :end_date]
    remove_index  :initiatives, [:project_id, :name]
    add_index     :initiatives, :project_id
    
    remove_index  :iterations, [:project_id, :name]
    add_index     :iterations, :project_id
    
    remove_index  :stories, :release_id
  end
end
