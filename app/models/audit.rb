class Audit < ActiveRecord::Base
  
  attr_protected :audit_ids, :user_id, :auditable_id, :auditable_type, :auditable_changes ### don't allow passing any of these values in mass!! .. 
  
  belongs_to :auditable, :polymorphic => true
  belongs_to :user
  
  serialize :auditable_changes
  
  scope :for, lambda { |x| { :conditions => ["auditable_type = ? and auditable_id = ?", x.class.name, x.id] } }
  scope :updates, where(:action => "update")
  scope :creates, where(:action => "create")
  scope :deletes, where(:action => "delete")
  
  before_create :set_readonly
  
  before_destroy :stop_destroy
  
  @@skip_fields = { 
    "User" => [:last_request_at, :perishable_token, :failed_login_count, :current_login_at, :login_count, :last_login_at, :current_login_ip, :last_login_ip, :single_access_token, :persistence_token],
    "Story" => [:updater_id, :creator_id]
  }
  
  def self.create!(model, action)
    exceptions = @@skip_fields[model.class.name].collect{|x|x.to_s} if @@skip_fields.member?(model.class.name)

    user = User.current_user
    return unless user
    a = Audit.new
    a.user_id = user.id
    a.project_id = model.project_id if model.respond_to?(:project_id)
    a.auditable_id = model.id
    a.auditable_type = model.class.name
    a.action = action.to_s
    final_changes = a.auditable_changes = model.changes.except("created_at", "updated_at", *exceptions) ### obv updated_at will change every time :)
    return unless final_changes.present?
    a.save!
  end
  
  protected
  
  def set_readonly
    self.readonly!
  end
  
  def stop_destroy
    raise 'CANNOT DELETE AUDIT RECORDS!!'
  end
  
end
