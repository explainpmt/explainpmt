class User < ActiveRecord::Base
  has_and_belongs_to_many :projects
  has_many :stories

  validates_presence_of :first_name, :last_name, :email, :username, :password
  validates_uniqueness_of :username, :email
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/

  def full_name(last_first = false)
    if last_first
      "#{last_name}, #{first_name}"
    else
      "#{first_name} #{last_name}"
    end
  end

  def self.authenticate(username, password)
    find_by_username_and_password(username, password)
  end
end
