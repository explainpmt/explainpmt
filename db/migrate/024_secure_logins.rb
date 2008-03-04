class SecureLogins < ActiveRecord::Migration
  def self.up
    add_column :users, :salt, :string
    User.find(:all).each do |user|
      user.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user.username}--")
      user.save
    end
  end

  def self.down
  end
end
