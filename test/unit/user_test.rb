require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @admin = User.find(1)
    @user = User.find(2)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of User,  @user
  end

  def test_create_user
    new_user = User.new
    new_user.id = 3
    new_user.admin = 0
    new_user.login = "user_three"
    new_user.password = "user_three"
    new_user.email = "userthree@localhost"
    new_user.name = "User Three"  
    assert new_user.save
    assert_equal 3, User.find(3).id
    assert_equal "User Three", User.find(3).name
  end
  
  def test_read_user
    assert_equal "admin", @admin.login
    assert_equal 1, @admin.admin
    assert_equal "Admin", @admin.name
  end

  def test_update_user
    assert_equal "user", @user.login
    assert_equal "User", @user.name
    @user.login = "changed"
    @user.name = "Who's name?"
    assert @user.save
    assert "changed", @user.login
    assert "Who's name?", @user.name  
  end

  def test_destroy_user
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { User.find(@user.id) }
  end
end
