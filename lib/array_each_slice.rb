


class Array
  def each_slice(size, &block)
    array = self.dup
    until array.empty?
      slice = []
      size.times { slice << array.shift }
      yield slice.reject { |x| x.nil? }
    end
  end
end