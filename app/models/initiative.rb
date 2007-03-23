class Initiative < ActiveRecord::Base
  belongs_to :project
  has_many :stories, :dependent => :nullify
  validates_presence_of :name
  validates_length_of :name, :maximum => 100
end
