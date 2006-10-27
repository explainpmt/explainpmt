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
require 'array_each_slice'
class ArrayEachSliceTest < Test::Unit::TestCase
  def test_each_slice
    a = [1,2,3,4,5,6,7,8,9]
    expected = [[1,2,3],[4,5,6],[7,8,9]]
    result = []
    a.each_slice 3 do |slice|
      result << slice
    end
    assert_equal expected, result
  end
  
  def test_each_slice_does_not_modify_receiver
    a = [1,2,3]
    b = a.dup
    a.each_slice 3 do |slice|
      slice
    end
    assert_equal b, a
  end
end