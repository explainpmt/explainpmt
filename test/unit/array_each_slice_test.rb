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