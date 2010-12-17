module Position
  
  def self.included(model)
    model.extend ClassMethods
    model.send(:include, InstanceMethods)
    
    model.class_eval do
      after_destroy :update_positions
      after_create :set_initial_position
      # allow specifying custom ordering with scope :ordered ... if exists, use, otherwise default to position
      # default_scope (respond_to?(:ordered) ? ordered : order("position"))
    end
  end
  
  module ClassMethods
    def update_positions!(ids)
      update_all(["position=find_in_set(id, ?) where id in(?)", ids.join(","), ids.map(&:to_i)])
    end
  end
  
  module InstanceMethods
    def select_ids
      connection.select_values("select id from #{self.class.table_name} order by position").map(&:to_i)
    end
    
    def set_initial_position
      insert_at(0)
    end
    
    def insert_at(index)
      ids = select_ids
      ids.delete(self.id)
      ids.insert(index, self.id)
      self.class.update_positions!(ids)
      self.position = index
    end
    
    def update_positions
      ids = select_ids
      self.class.update_positions!(ids)
    end
  end
  
end