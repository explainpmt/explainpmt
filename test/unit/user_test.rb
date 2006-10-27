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


require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  
  def setup
    @user_one = User.find 1
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
