module StateMachine
  module Integrations #:nodoc:
    # Adds support for integrating state machines with MongoMapper models.
    # 
    # == Examples
    # 
    # Below is an example of a simple state machine defined within a
    # MongoMapper model:
    # 
    #   class Vehicle
    #     include MongoMapper::Document
    #     
    #     state_machine :initial => :parked do
    #       event :ignite do
    #         transition :parked => :idling
    #       end
    #     end
    #   end
    # 
    # The examples in the sections below will use the above class as a
    # reference.
    # 
    # == Actions
    # 
    # By default, the action that will be invoked when a state is transitioned
    # is the +save+ action.  This will cause the record to save the changes
    # made to the state machine's attribute.  *Note* that if any other changes
    # were made to the record prior to transition, then those changes will
    # be saved as well.
    # 
    # For example,
    # 
    #   vehicle = Vehicle.create          # => #<Vehicle id: 1, name: nil, state: "parked">
    #   vehicle.name = 'Ford Explorer'
    #   vehicle.ignite                    # => true
    #   vehicle.reload                    # => #<Vehicle id: 1, name: "Ford Explorer", state: "idling">
    # 
    # == Events
    # 
    # As described in StateMachine::InstanceMethods#state_machine, event
    # attributes are created for every machine that allow transitions to be
    # performed automatically when the object's action (in this case, :save)
    # is called.
    # 
    # In MongoMapper, these automated events are run in the following order:
    # * before validation - Run before callbacks and persist new states, then validate
    # * before save - If validation was skipped, run before callbacks and persist new states, then save
    # * after save - Run after callbacks
    # 
    # For example,
    # 
    #   vehicle = Vehicle.create          # => #<Vehicle id: 1, name: nil, state: "parked">
    #   vehicle.state_event               # => nil
    #   vehicle.state_event = 'invalid'
    #   vehicle.valid?                    # => false
    #   vehicle.errors.full_messages      # => ["State event is invalid"]
    #   
    #   vehicle.state_event = 'ignite'
    #   vehicle.valid?                    # => true
    #   vehicle.save                      # => true
    #   vehicle.state                     # => "idling"
    #   vehicle.state_event               # => nil
    # 
    # Note that this can also be done on a mass-assignment basis:
    # 
    #   vehicle = Vehicle.create(:state_event => 'ignite')  # => #<Vehicle id: 1, name: nil, state: "idling">
    #   vehicle.state                                       # => "idling"
    # 
    # This technique is always used for transitioning states when the +save+
    # action (which is the default) is configured for the machine.
    # 
    # === Security implications
    # 
    # Beware that public event attributes mean that events can be fired
    # whenever mass-assignment is being used.  If you want to prevent malicious
    # users from tampering with events through URLs / forms, the attribute
    # should be protected like so:
    # 
    #   class Vehicle
    #     include MongoMapper::Document
    #     
    #     attr_protected :state_event
    #     # attr_accessible ... # Alternative technique
    #     
    #     state_machine do
    #       ...
    #     end
    #   end
    # 
    # If you want to only have *some* events be able to fire via mass-assignment,
    # you can build two state machines (one public and one protected) like so:
    # 
    #   class Vehicle
    #     include MongoMapper::Document
    #     
    #     attr_protected :state_event # Prevent access to events in the first machine
    #     
    #     state_machine do
    #       # Define private events here
    #     end
    #     
    #     # Public machine targets the same state as the private machine
    #     state_machine :public_state, :attribute => :state do
    #       # Define public events here
    #     end
    #   end
    # 
    # == Validation errors
    # 
    # If an event fails to successfully fire because there are no matching
    # transitions for the current record, a validation error is added to the
    # record's state attribute to help in determining why it failed and for
    # reporting via the UI.
    # 
    # For example,
    # 
    #   vehicle = Vehicle.create(:state => 'idling')  # => #<Vehicle id: 1, name: nil, state: "idling">
    #   vehicle.ignite                                # => false
    #   vehicle.errors.full_messages                  # => ["State cannot transition via \"ignite\""]
    # 
    # If an event fails to fire because of a validation error on the record and
    # *not* because a matching transition was not available, no error messages
    # will be added to the state attribute.
    # 
    # == Scopes
    # 
    # To assist in filtering models with specific states, a series of basic
    # scopes are defined on the model for finding records with or without a
    # particular set of states.
    # 
    # These scopes are essentially the functional equivalent of the following
    # definitions:
    # 
    #   class Vehicle
    #     include MongoMapper::Document
    #     
    #     def self.with_states(*states)
    #       all(:conditions => {:state => {'$in' => states}})
    #     end
    #     # with_states also aliased to with_state
    #     
    #     def self.without_states(*states)
    #       all(:conditions => {:state => {'$nin' => states}})
    #     end
    #     # without_states also aliased to without_state
    #   end
    # 
    # *Note*, however, that the states are converted to their stored values
    # before being passed into the query.
    # 
    # Because of the way named scopes work in MongoMapper, they *cannot* be
    # chained.
    # 
    # == Callbacks
    # 
    # All before/after transition callbacks defined for MongoMapper models
    # behave in the same way that other MongoMapper callbacks behave.  The
    # object involved in the transition is passed in as an argument.
    # 
    # For example,
    # 
    #   class Vehicle
    #     include MongoMapper::Document
    #     
    #     state_machine :initial => :parked do
    #       before_transition any => :idling do |vehicle|
    #         vehicle.put_on_seatbelt
    #       end
    #       
    #       before_transition do |vehicle, transition|
    #         # log message
    #       end
    #       
    #       event :ignite do
    #         transition :parked => :idling
    #       end
    #     end
    #     
    #     def put_on_seatbelt
    #       ...
    #     end
    #   end
    # 
    # Note, also, that the transition can be accessed by simply defining
    # additional arguments in the callback block.
    module MongoMapper
      include ActiveModel
      
      # The default options to use for state machines using this integration
      @defaults = {:action => :save}
      
      # Should this integration be used for state machines in the given class?
      # Classes that include MongoMapper::Document will automatically use the
      # MongoMapper integration.
      def self.matches?(klass)
        defined?(::MongoMapper::Document) && klass <= ::MongoMapper::Document
      end
      
      # Adds a validation error to the given object (no i18n support)
      def invalidate(object, attribute, message, values = [])
        object.errors.add(self.attribute(attribute), generate_message(message, values))
      end
      
      protected
        # Does not support observers
        def supports_observers?
          false
        end
        
        # Always adds validation support
        def supports_validations?
          true
        end
        
        # Only runs validations on the action if using <tt>:save</tt>
        def runs_validations_on_action?
          action == :save
        end
        
        # Always adds dirty tracking support
        def supports_dirty_tracking?(object)
          true
        end
        
        # Don't allow callback terminators
        def callback_terminator
        end
        
        # Defines an initialization hook into the owner class for setting the
        # initial state of the machine *before* any attributes are set on the
        # object
        def define_state_initializer
          @instance_helper_module.class_eval <<-end_eval, __FILE__, __LINE__
            def initialize(attrs = {}, *args)
              from_database = args.first
              
              if !from_database && (!attrs || !attrs.stringify_keys.key?('_id'))
                filtered = respond_to?(:filter_protected_attrs) ? filter_protected_attrs(attrs) : attrs 
                ignore = filtered ? filtered.keys : []
                
                initialize_state_machines(:dynamic => false, :ignore => ignore)
                super
                initialize_state_machines(:dynamic => true, :ignore => ignore)
              else
                super
              end
            end
          end_eval
        end
        
        # Skips defining reader/writer methods since this is done automatically
        def define_state_accessor
          owner_class.key(attribute, String) unless owner_class.keys.include?(attribute)
          
          name = self.name
          owner_class.validates_each(attribute, :logic => lambda {|*|
            machine = self.class.state_machine(name)
            machine.invalidate(self, :state, :invalid) unless machine.states.match(self)
          })
        end
        
        # Adds support for defining the attribute predicate, while providing
        # compatibility with the default predicate which determines whether
        # *anything* is set for the attribute's value
        def define_state_predicate
          name = self.name
          
          # Still use class_eval here instance of define_instance_method since
          # we need to be able to call +super+
          @instance_helper_module.class_eval do
            define_method("#{name}?") do |*args|
              args.empty? ? super(*args) : self.class.state_machine(name).states.matches?(self, *args)
            end
          end
        end
        
        # Adds hooks into validation for automatically firing events
        def define_action_helpers
          super(action == :save ? :create_or_update : action)
        end
        
        # Creates a scope for finding records *with* a particular state or
        # states for the attribute
        def create_with_scope(name)
          lambda {|model, values| model.all(:conditions => {attribute => {'$in' => values}})}
        end
        
        # Creates a scope for finding records *without* a particular state or
        # states for the attribute
        def create_without_scope(name)
          lambda {|model, values| model.all(:conditions => {attribute => {'$nin' => values}})}
        end
    end
  end
end
