##############################################################################
# eXPlain Project Management Tool
# Copyright (C) 2005  John Wilger <johnwilger@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##############################################################################

class CreateInitialDatabase < ActiveRecord::Migration
  class User < ActiveRecord::Base; end

  def self.up
    create_table :iterations do |t|
      t.column :project_id, :integer
      t.column :start_date, :date
      t.column :length, :integer
      t.column :budget, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :milestones do |t|
      t.column :project_id, :integer
      t.column :date, :date
      t.column :name, :string
      t.column :description, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :projects do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :projects_users, :id => false do |t|
      t.column :user_id, :integer
      t.column :project_id, :integer
    end

    create_table :stories do |t|
      t.column :scid, :integer
      t.column :project_id, :integer
      t.column :iteration_id, :integer
      t.column :user_id, :integer
      t.column :title, :string
      t.column :points, :integer
      t.column :status, :integer
      t.column :priority, :integer
      t.column :risk, :integer
      t.column :description, :text
    end

    create_table :users do |t|
      t.column :username, :string
      t.column :password, :string
      t.column :email, :string
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :admin, :boolean
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    # Create the initial admin user
    User.create :username => 'admin', :password => 'admin', :email => 'admin@example.com', :first_name => 'admin',
      :last_name => 'admin', :admin => true
  end

  def self.down
    drop_table :iterations
    drop_table :milestones
    drop_table :projects
    drop_table :projects_users
    drop_table :stories
    drop_table :users
  end
end