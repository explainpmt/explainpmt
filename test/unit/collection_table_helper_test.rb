require File.dirname(__FILE__) + '/../test_helper'
require 'collection_table_helper'

class CollectionTableHelperTest < Test::Unit::TestCase
  TestItem = Struct.new(:id, :name, :phone)
  TestItemB = Struct.new(:id, :phone)
  def setup
    @items = [ TestItem.new(1, 'John Doe', '555-5555'),
              TestItem.new(2, 'Jane Doe', '666-6666') ]
  end
  
  def test_collection_table_initialize
    assert_nothing_raised {
      ct = CollectionTableHelper::CollectionTable.new(@items, :id, :name,
                                                      :phone)
    }
  end

  def test_heading_for
    ct = CollectionTableHelper::CollectionTable.new(@items, [:id,'ID'], :name,
                                                    :phone, [:edit,nil],
                                                    [:delete,''])
    assert_equal 'ID', ct.send(:heading_for, :id)
    assert_equal 'Name', ct.send(:heading_for, :name)
    assert_equal 'Phone', ct.send(:heading_for, :phone)
    assert_equal '', ct.send(:heading_for, :edit)
    assert_equal '', ct.send(:heading_for, :delete)
    assert_raises(RuntimeError) { ct.send(:heading_for, :not_a_column) }
  end

  def test_item_id_attribute
    @items << TestItemB.new(3, '777-7777')
    ct = CollectionTableHelper::CollectionTable.new(@items, :name, :phone)
    assert_equal :id, ct.item_id_attr

    assert_nothing_raised { ct.item_id_attr = :phone }
    assert_equal :phone, ct.item_id_attr

    # TestItemB class has no 'name' attribute
    assert_raises(RuntimeError) { ct.item_id_attr = :name }
  end

  def test_header_row
    ct = CollectionTableHelper::CollectionTable.new(@items, [:id,'ID'], :name,
                                                    :phone)
    expected = "  <tr>\n    <th>ID</th>\n    <th>Name</th>\n" +
               "    <th>Phone</th>\n  </tr>\n"
    assert_equal expected, ct.send(:header_row)
  end

  def test_data_row
    ct = CollectionTableHelper::CollectionTable.new(@items, :id, :name, :phone)
    item = @items.first
    expected = "  <tr>\n    <td>#{item.id}</td>\n" +
               "    <td>#{item.name}</td>\n    <td>#{item.phone}</td>\n" +
               "  </tr>\n"
    assert_equal expected, ct.send(:data_row, item)
  end

  def test_column_modifier
    ct = CollectionTableHelper::CollectionTable.new(@items, :id, :name, :phone,
                                                    :edit)
    ct.column_modifier(:phone) { |item|
      item.phone.gsub('-', '#')
    }
    ct.column_modifier(:edit) { |item|
      "<a href=\"/item/edit/#{item.id}\">Edit</a>"
    }
    item = @items.first
    expected = "  <tr>\n    <td>#{item.id}</td>\n" +
               "    <td>#{item.name}</td>\n" +
               "    <td>#{item.phone.gsub('-','#')}</td>\n" +
               "    <td><a href=\"/item/edit/#{item.id}\">Edit</a></td>\n" +
               "  </tr>\n"
    assert_equal expected, ct.send(:data_row, item)
  end

  def test_alternating_data_row_classes
    ct = CollectionTableHelper::CollectionTable.new(@items, :id, :name, :phone)
    @items << @items.first
    ct.data_row_class = [ 'odd_row', 'even_row' ]
    item = @items.shift
    assert(/<tr class="odd_row"/ =~ ct.send(:data_row, item))
    item = @items.shift
    assert(/<tr class="even_row"/ =~ ct.send(:data_row, item))
    item = @items.shift
    assert(/<tr class="odd_row"/ =~ ct.send(:data_row, item))
  end

  def test_column_align
    ct = CollectionTableHelper::CollectionTable.new(@items, :id)
    ct.column_align(:id, 'right')
    item = @items.shift
    expected = "  <tr>\n    <td align=\"right\">#{item.id}</td>\n  </tr>\n"
    assert_equal expected, ct.send(:data_row, item)
  end

  def test_build_table
    ct = CollectionTableHelper::CollectionTable.new(@items, [:id,'ID'], :name,
                                                    :phone)
    ct.data_row_class = [ 'odd_row', 'even_row' ]
    expected = <<EOF
<table class="collection_table">
  <tr>
    <th>ID</th>
    <th>Name</th>
    <th>Phone</th>
  </tr>
  <tr class="odd_row">
    <td>1</td>
    <td>John Doe</td>
    <td>555-5555</td>
  </tr>
  <tr class="even_row">
    <td>2</td>
    <td>Jane Doe</td>
    <td>666-6666</td>
  </tr>
</table>
EOF
    assert_equal expected, ct.build_table
  end
end
