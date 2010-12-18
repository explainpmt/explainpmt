require 'fastercsv'
require 'hash_object'

class DataLoader
  
  attr_accessor :conn, :raw_conn, :config, :path_to_files
  
  class << self
    def run!
      tl = new
      tl.run
    end
  end
  
  def initialize
    @config = Rails.configuration.database_configuration[Rails.env]
    @path_to_files = File.join(Rails.root, "db")
    connect
  end
  
  def run
    tables = conn.tables
    tables.delete("schema_migrations")
    tables.each do |table|
      x = conn.select_all("select * from #{table}")
      next unless x.present?
      FCSV.open("#{path_to_files}/#{table}.csv", "w") do |csv|
        csv << x.first.keys
        x.each do |row|
          csv << row.values
        end
      end
    end
    
    # reset, re-seed the db first...
    Rake::Task['db:reset'].invoke
    Rake::Task['db:seed'].invoke
    
    # re-establish connection :( , thanks Rake.
    connect
    
    ## import the easy ones first
    easy = tables - %w(users acceptancetests project_memberships audits)
    
    easy.each do |table|
      file = "#{path_to_files}/#{table}.csv"
      next unless File.exists?(file)
      p "importing #{table}"
      
      data = FCSV.read(file, :headers => true).to_a
      keys = data.shift
      col_count = keys.size
      
      stmt = raw_conn.prepare(prepared_sql(table, col_count))
      
      data.each do |row|
        stmt.execute(*row)
      end
      raw_conn.commit
    end
    
    # # DO NOT do any creates here... we want our old associations, passwords, etc. so this is simply a migration of data.
    
    user_sql = raw_conn.prepare(
    <<-EOF
      INSERT INTO users (id,login,email,crypted_password,salt,persistence_token,single_access_token,perishable_token,is_admin,team,first_name,last_name,last_login_at,created_at,updated_at)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    EOF
    )
    
    run_section(:users) do |user|
      user_sql.execute(user['id'], user.username, user.email, user.password, user.salt, SecureRandom.hex(64), generate_random_token, generate_random_token, user.admin, user.team, user.first_name, user.last_name, user.last_login, user.created_at, user.updated_at)
    end
    
    at_sql = raw_conn.prepare(
    <<-EOF
      INSERT INTO acceptance_tests (id,name,automated,project_id,pre_condition,post_condition,expected_result,description,story_id,pass,created_at,updated_at)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
    EOF
    )
    
    run_section(:acceptancetests) do |at|
      at_sql.execute(at['id'], at.name, at.automated, at.project_id, at.pre_condition, at.post_condition, at.expected_result, at.description, at.story_id, at.pass, "now()", "now()")
    end
    
    pm_sql = raw_conn.prepare(
    <<-EOF
      INSERT INTO projects_users (user_id,project_id)
      VALUES (?,?)
    EOF
    )
    
    run_section(:project_memberships) do |pm|
      pm_sql.execute(pm.user_id, pm.project_id)
    end
    
    audit_sql = raw_conn.prepare(
    <<-EOF
      INSERT INTO audits (id,auditable_id,auditable_type,project_id,user_id,action,auditable_changes,created_at)
      VALUES (?,?,?,?,?,?,?,?)
    EOF
    )
    
    ## TODO => definitely some repetition, can it be dryed up?
    run_section(:audits) do |audit|
      before_old = audit.before.split("\n")
      before_new = {}
      before_old.each do |c|
        b = c.match(/(.+)\[(.+)\]/).to_a
        before_new[b[1]] = b[2]
      end
      after_old = audit.after.split("\n")
      after_new = {}
      after_old.each do |c|
        b = c.match(/(.+)\[(.+)\]/).to_a
        after_new[b[1]] = b[2]
      end
      changes = {}
      before_new.keys.each do |k|
        changes[k] = [before_new[k], after_new[k]]
      end
      audit_sql.execute(audit['id'], audit.audited_object_id, audit.object, audit.project_id, audit.user, "unknown", YAML.dump(changes), audit.created_at)
    end
    
  end
  
  def cleanse_row(row)
    row.each do |k,v|
      c = v.blank? ? nil : (v.match(/^\d+$/) ? v.to_i : v)
      row[k] = c
    end
    row
  end
  
  def prepared_sql(table,col_count)
    sql = "INSERT into #{table} VALUES ("
    col_count.times do |i|
      sql << "?,"
    end
    sql.chomp!(",")
    sql << ")"
  end

  def run_section(section, &block)
    return unless File.exist?("#{path_to_files}/#{section}.csv")
    FCSV.foreach("#{path_to_files}/#{section}.csv", :headers => true) do |row|
      row = cleanse_row(row.to_hash)
      HashObject.extend_hash(:String,row)
      yield row
    end
    raw_conn.commit
  end
  
  def connect
    ActiveRecord::Base.establish_connection(config)
    @conn = ActiveRecord::Base.connection
    @raw_conn = @conn.raw_connection
    @raw_conn.autocommit(false)
  end
  
  def generate_random_token
    SecureRandom.base64(15).tr('+/=', '-_ ').strip.delete("\n")
  end
  
end