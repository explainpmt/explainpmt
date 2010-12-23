require 'test_helper'

class AuditTest < ActiveSupport::TestCase
  
  context "A new audit" do
    setup do
      @audit = Audit.new
    end
    
    should belong_to(:auditable)
    should belong_to(:user)
    should_not allow_mass_assignment_of(:audit_ids)
    should_not allow_mass_assignment_of(:user_id)
    should_not allow_mass_assignment_of(:auditable_id)
    should_not allow_mass_assignment_of(:auditable_type)
    should_not allow_mass_assignment_of(:auditable_changes)
  end
  
  context "An audit instance" do
    setup do
      @audit = audits(:story_audit)
    end
    
    should "be readonly" do
      assert @audit.readonly?
    end
    
    should "not be destroyable" do
      assert_raise(RuntimeError) do
        @audit.destroy
      end
    end
  end
  
end
