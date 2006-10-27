require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  def setup
    User.destroy_all
    create_common_fixtures :user_one
  end
  
  def test_full_name
    assert_equal("#{@user_one.first_name} #{@user_one.last_name}",
                 @user_one.full_name)
    assert_equal("#{@user_one.last_name}, #{@user_one.first_name}",
                 @user_one.full_name(User::LastFirst))
  end

  def test_authenticate
    assert_equal(@user_one,
                 User.authenticate(@user_one.username, @user_one.password))
  end

  def test_authenticate_bad_password
    assert_nil User.authenticate(@user_one.username, 'bad_password')
    assert_nil User.authenticate(@user_one.username, nil)
  end

  def test_authenticate_bad_username
    assert_nil User.authenticate('bad_username', @user_one.password)
    assert_nil User.authenticate(nil, @user_one.password)
  end

  def test_authenticate_bad_username_and_password
    assert_nil User.authenticate('bad_username', 'bad_password')
    assert_nil User.authenticate(nil, nil)
  end
  
  def test_username_validations
    @user_one.username = '_' * 1
    @user_one.valid?
    assert_nil @user_one.errors[:username]
  end
  
  def test_password_validations
    @user_one.password = '_' * 1
    @user_one.valid?
    assert_nil @user_one.errors[:password]
  end
end



