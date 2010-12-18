class AuditObserver < ActiveRecord::Observer
  
  ## TODO => figure out what else to audit??
  observe :story
  
  def after_create(model)
    audit!(model, :create)
  end
  
  def after_update(model)
    (model.respond_to?(:deleted_at) && !model.deleted_at.nil?) ? audit!(model, :delete) : audit!(model, :update)
  end
  
  protected
  
  def audit!(model, action)
    Audit.create!(model, action)
  end
  
end