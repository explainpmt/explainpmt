# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101216190927) do

  create_table "acceptance_tests", :force => true do |t|
    t.string   "name"
    t.string   "string"
    t.boolean  "automated",       :default => false
    t.integer  "project_id"
    t.text     "pre_condition"
    t.text     "post_condition"
    t.text     "expected_result"
    t.text     "description"
    t.integer  "story_id"
    t.boolean  "pass",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "acceptance_tests", ["project_id"], :name => "index_acceptance_tests_on_project_id"
  add_index "acceptance_tests", ["story_id"], :name => "index_acceptance_tests_on_story_id"

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "action"
    t.text     "auditable_changes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audits", ["auditable_type", "auditable_id"], :name => "auditable_index"
  add_index "audits", ["project_id"], :name => "index_audits_on_project_id"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"

  create_table "initiatives", :force => true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "customer"
    t.string   "product_owner"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "initiatives", ["project_id", "name"], :name => "index_initiatives_on_project_id_and_name", :unique => true
  add_index "initiatives", ["start_date", "end_date"], :name => "index_initiatives_on_start_date_and_end_date"

  create_table "iterations", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.date     "start_date"
    t.integer  "length"
    t.integer  "budget"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "iterations", ["project_id", "name"], :name => "index_iterations_on_project_id_and_name", :unique => true
  add_index "iterations", ["start_date"], :name => "index_iterations_on_start_date"

  create_table "milestones", :force => true do |t|
    t.integer  "project_id"
    t.integer  "integer"
    t.date     "date"
    t.string   "name"
    t.string   "string"
    t.text     "description"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "milestones", ["project_id"], :name => "index_milestones_on_project_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "planned_iterations"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  create_table "releases", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.integer  "project_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "releases", ["project_id"], :name => "index_releases_on_project_id"

  create_table "stories", :force => true do |t|
    t.integer  "scid"
    t.integer  "project_id"
    t.integer  "iteration_id"
    t.integer  "user_id"
    t.string   "title"
    t.integer  "points"
    t.integer  "status"
    t.integer  "value"
    t.integer  "risk"
    t.text     "description"
    t.integer  "position"
    t.string   "customer"
    t.integer  "initiative_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "release_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stories", ["initiative_id"], :name => "index_stories_on_initiative_id"
  add_index "stories", ["iteration_id"], :name => "index_stories_on_iteration_id"
  add_index "stories", ["project_id", "position"], :name => "index_stories_on_project_id_and_position"
  add_index "stories", ["release_id"], :name => "index_stories_on_release_id"
  add_index "stories", ["user_id"], :name => "index_stories_on_user_id"

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "complete",    :default => false
    t.integer  "story_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["story_id"], :name => "index_tasks_on_story_id"
  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.boolean  "is_admin",            :default => false, :null => false
    t.string   "team"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
  end

end
