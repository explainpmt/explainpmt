module StateMachine
  module Integrations #:nodoc:
    # Adds support for integrating state machines with DataMapper resources.
    # 
    # == Examples
    # 
    # Below is an example of a simple state machine defined within a
    # DataMapper resource:
    # 
    #   class Vehicle
    #     include DataMapper::Resource
    #     
    #     property :id, Serial
    #     property :name, String
    #     property :state, String
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
    # is the +save+ action.  This will cause the resource to save the changes
    # made to the state machine's attribute.  *Note* that if any other changes
    # were made to the resource prior to transition, then those changes will
    # be saved as well.
    # 
    # For example,
    # 
    #   vehicle = Vehicle.create          # => #<Vehicle id=1 name=nil state="parked">
    #   vehicle.name = 'Ford Explorer'
    #   vehicle.ignite                    # => true
    #   vehicle.reload                    # => #<Vehicle id=1 name="Ford Explorer" state="idling">
    # 
    # == Events
    # 
    # As described in StateMachine::InstanceMethods#state_machine, event
    # attributes are created for every machine that allow transitions to be
    # performed automatically when the object's action (in this case, :save)
    # is called.
    # 
    # In DataMapper, these automated events are run in the following order:
    # * before validation - If validation feature loaded, run before callbacks and persist new states, then validate
    # * before save - If validation feature was skipped/not loaded, run before callbacks and persist new states, then save
    # * after save - Run after callbacks
    # 
    # For example,
    # 
    #   vehicle = Vehicle.create          # => #<Vehicle id=1 name=nil state="parked">
    #   vehicle.state_event               # => nil
    #   vehicle.state_event = 'invalid'
    #   vehicle.valid?                    # => false
    #   vehicle.errors                    # => #<DataMapper::Validate::ValidationErrors:0xb7a48b54 @errors={"state_event"=>["is invalid"]}>
    #   
    #   vehicle.state_event = 'ignite'
    #   vehicle.valid?                    # => true
    #   vehicle.save                      # => true
    #   vehicle.state                     # => "idling"
    #   vehicle.state_event               # => nil
    # 
    # Note that this can also be done on a mass-assignment basis:
    # 
    #   vehicle = Vehicle.create(:state_event => 'ignite')  # => #<Vehicle id=1 name=nil state="idling">
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
    #     include DataMapper::Resource
    #     ...
    #     
    #     state_machine do
    #       ...
    #     end
    #     protected :state_event
    #   end
    # 
    # If you want to only have *some* events be able to fire via mass-assignment,
    # you can build two state machines (one public and one protected) like so:
    # 
    #   class Vehicle
    #     include DataMapper::Resource
    #     ...
    #     
    #     state_machine do
    #       # Define private events here
    #     end
    #     protected :state_event= # Prevent access to events in the first machine
    #     
    #     # Allow both machines to share the same state
    #     state_machine :public_state, :attribute => :state do
    #       # Define public events here
    #     end
    #   end
    # 
    # == Transactions
    # 
    # By default, the use of transactions during an event transition is
    # turned off to be consistent with DataMapper.  This means that if
    # changes are made to the database during a before callback, but the
    # transition fails to complete, those changes will *not* be rolled back.
    # 
    # For example,
    # 
    #   class Message
    #     include DataMapper::Resource
    #     
    #     property :id, Serial
    #     property :content, String
    #   end
    #   
    #   Vehicle.state_machine do
    #     before_transition do |transition|
    #       Message.create(:content => transition.inspect)
    #       throw :halt
    #     end
    #   end
    #   
    #   vehicle = Vehicle.create      # => #<Vehicle id=1 name=nil state="parked">
    #   vehicle.ignite                # => false
    #   Message.all.count             # => 1
    # 
    # To turn on transactions:
    # 
    #   class Vehicle < ActiveRecord::Base
    #     state_machine :initial => :parked, :use_transactions => true do
    #       ...
    #     end
    #   end
    # 
    # If using the +save+ action for the machine, this option will be ignored as
    # the transaction behavior will depend on the +save+ implementation within
    # DataMapper.
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
    #   vehicle = Vehicle.create(:state => 'idling')  # => #<Vehicle id=1 name=nil state="idling">
    #   vehicle.ignite                                # => false
    #   vehicle.errors.full_messages                  # => ["cannot transition via \"ignite\""]
    # 
    # If an event fails to fire because of a validation error on the record and
    # *not* because a matching transition was not available, no error messages
    # will be added to the state attribute.
    # 
    # == Scopes
    # 
    # To assist in filtering models with specific states, a series of class
    # methods are defined on the model for finding records with or without a
    # particular set of states.
    # 
    # These named scopes are the functional equivalent of the following
    # definitions:
    # 
    #   class Vehicle
    #     include DataMapper::Resource
    #     
    #     property :id, Serial
    #     property :state, String
    #     
    #     class << self
    #       def with_states(*states)
    #         all(:state => states.flatten)
    #       end
    #       alias_method :with_state, :with_states
    #       
    #       def without_states(*states)
    #         all(:state.not => states.flatten)
    #       end
    #       alias_method :without_state, :without_states
    #     end
    #   end
    # 
    # *Note*, however, that the states are converted to their stored values
    # before being passed into the query.
    # 
    # Because of the way scopes work in DataMapper, they can be chained like
    # so:
    # 
    #   Vehicle.with_state(:parked).all(:order => [:id.desc])
    # 
    # == Callbacks / Observers
    # 
    # All before/after transition callbacks defined for DataMapper resources
    # behave in the same way that other DataMapper hooks behave.  Rather than
    # passing in the record as an argument to the callback, the callback is
    # instead bound to the object and evaluated within its context.
    # 
    # For example,
    # 
    #   class Vehicle
    #     include DataMapper::Resource
    #     
    #     property :id, Serial
    #     property :state, String
    #     
    #     state_machine :initial => :parked do
    #       before_transition any => :idling do
    #         put_on_seatbelt
    #       end
    #       
    #       before_transition do |transition|
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
    # 
    # In addition to support for DataMapper-like hooks, there is additional
    # support for DataMapper observers.  See StateMachine::Integrations::DataMapper::Observer
    # for more information.
    module DataMapper
      # The default options to use for state machines using this integration
      class << self; attr_reader :defaults; end
      @defaults = {:action => :save, :use_transactions => false}
        
      # Should this integration be used for state machines in the given class?
      # Classes that include DataMapper::Resource will automatically use the
      # DataMapper integration.
      def self.matches?(klass)
        defined?(::DataMapper::Resource) && klass <= ::DataMapper::Resource
      end
      
      # Loads additional files specific to DataMapper
      def self.extended(base) #:nodoc:
        require 'dm-core/version' unless ::DataMapper.const_defined?('VERSION')
        require 'state_machine/integrations/data_mapper/observer' if ::DataMapper.const_defined?('Observer')
      end
      
      # Forces the change in state to be recognized regardless of whether the
      # state value actually changed
      def write(object, attribute, value)
        if attribute == :state
          # Force to Dirty state in 0.10.3+
          if !(::DataMapper::VERSION =~ /^0\.(9\.|10\.[0-2]$)/)
            object.persisted_state = ::DataMapper::Resource::State::Dirty.new(object) if object.persisted_state.is_a?(::DataMapper::Resource::State::Clean)
          end
          
          result = super
          
          # Change original attributes in 0.9.4 - 0.10.2
          if ::DataMapper::VERSION =~ /^0\.9\./
            object.original_values[self.attribute] = "#{value}-ignored" if object.original_values[self.attribute] == value
          elsif ::DataMapper::VERSION =~ /^0\.10\.[0-2]$/
            property = owner_class.properties[self.attribute]
            object.original_attributes[property] = "#{value}-ignored" unless object.original_attributes.include?(property)
          end
        else
          result = super
        end
        
        result
      end
      
      # Adds a validation error to the given object
      def invalidate(object, attribute, message, values = [])
        object.errors.add(self.attribute(attribute), generate_message(message, values)) if supports_validations?
      end
      
      # Resets any errors previously added when invalidating the given object
      def reset(object)
        object.errors.clear if supports_validations?
      end
      
      protected
        # Is validation support currently loaded?
        def supports_validations?
          @supports_validations ||= ::DataMapper.const_defined?('Validate')
        end
        
        # Pluralizes the name using the built-in inflector
        def pluralize(word)
          defined?(Extlib::Inflection) ? Extlib::Inflection.pluralize(word.to_s) : super
        end
        
        # Defines an initialization hook into the owner class for setting the
        # initial state of the machine *before* any attributes are set on the
        # object
        def define_state_initializer
          @instance_helper_module.class_eval <<-end_eval, __FILE__, __LINE__
            def initialize(attributes = {}, *args)
              ignore = attributes ? attributes.keys : []
              initialize_state_machines(:dynamic => false, :ignore => ignore)
              super
              initialize_state_machines(:dynamic => true, :ignore => ignore)
            end
          end_eval
        end
        
        # Skips defining reader/writer methods since this is done automatically
        def define_state_accessor
          owner_class.property(attribute, String) unless owner_class.properties.detect {|property| property.name == attribute}
          
          if supports_validations?
            name = self.name
            owner_class.validates_with_block(attribute) do
              machine = self.class.state_machine(name)
              machine.states.match(self) ? true : [false, machine.generate_message(:invalid)]
            end
          end
        end
        
        # Adds hooks into validation for automatically firing events
        def define_action_helpers
          # 0.9.4 - 0.9.6 fails to run after callbacks when validations are
          # enabled because of the way dm-validations integrates
          return if ::DataMapper::VERSION =~ /^0\.9\.[4-6]/ && supports_validations?
          
          if action == :save
            if super(::DataMapper::VERSION =~ /^0\.\d\./ ? :save : :save_self) && supports_validations?
              @instance_helper_module.class_eval do
                define_method(:valid?) do |*args|
                  self.class.state_machines.transitions(self, :save, :after => false).perform { super(*args) }
                end
              end
            end
          else
            super
          end
        end
        
        # Creates a scope for finding records *with* a particular state or
        # states for the attribute
        def create_with_scope(name)
          lambda {|resource, values| resource.all(attribute => values)}
        end
        
        # Creates a scope for finding records *without* a particular state or
        # states for the attribute
        def create_without_scope(name)
          lambda {|resource, values| resource.all(attribute.to_sym.not => values)}
        end
        
        # Runs a new database transaction, rolling back any changes if the
        # yielded block fails (i.e. returns false).
        def transaction(object)
          object.class.transaction {|t| t.rollback unless yield}
        end
        
        # Creates a new callback in the callback chain, always ensuring that
        # it's configured to bind to the object as this is the convention for
        # DataMapper/Extlib callbacks
        def add_callback(type, options, &block)
          options[:bind_to_object] = true
          super
        end
    end
  end
end
