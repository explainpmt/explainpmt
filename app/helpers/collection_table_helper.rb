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


module CollectionTableHelper
  # Creates an HTML table based on any collection (Enumerable) of objects.
  #
  # Example:
  #
  #   # Assuming we have a Person model class with the attributes
  #   # id, last_name, first_name, email and we have assigned the
  #   # @people variable in the controller as @people = Person.find_all
  #   people_table = CollectionTable.new(@people, [:id,'ID'], :last_name,
  #     :first_name, :email, [:edit,nil], [:delete,nil])
  #   people_table.data_row_class = ['odd_row','even_row']
  #   people_table.column_align(:id, 'right')
  #   people_table.column_modifier(:email) do |p|
  #     "<a href=\"mailto:#{p.email}\">p.email</a>"
  #   end
  #   people_table.column_modifier(:edit) do |p|
  #     link_to('Edit', :controller => 'people', :action => 'edit',
  #       :id => p.id)
  #   end
  #   people_table.column_modifier(:delete) do |p|
  #     link_to('Delete', :controller => 'people', :action => 'delete',
  #       :id => p.id)
  #   end
  #   people_table.build_table
  #
  # Depending on the actual Person records in the collection, the call to
  # build_table might return the following HTML:
  #
  #   <table class="collection_table">
  #     <thead>
  #       <tr>
  #         <th>ID</th>
  #         <th>Last Name</th>
  #         <th>First Name</th>
  #         <th>Email</th>
  #         <th></th>
  #         <th></th>
  #       </tr>
  #     </thead>
  #     <tbody>
  #       <tr class="odd_row">
  #         <td align="right">2</td>
  #         <td>Doe</td>
  #         <td>Jane</td>
  #         <td><a href="mailto:janedoe@example.com">janedoe@example.com</a></td>
  #         <td><a href="/people/edit/2">Edit</a></td>
  #         <td><a href="/people/delete/2">Delete</a></td>
  #       </tr>
  #       <tr class="even_row">
  #         <td align="right">3</td>
  #         <td>Body</td>
  #         <td>Some</td>
  #         <td><a href="mailto:somebody@example.com">somebody@example.com</a></td>
  #         <td><a href="/people/edit/3">Edit</a></td>
  #         <td><a href="/people/delete/3">Delete</a></td>
  #       </tr>
  #     </tbody>
  #   </table>
  class CollectionTable
    # The attribute of each item in the collection that can be used as a unique
    # identifier. Defaults to the +id+ attribute.
    attr_accessor :item_id_attr

    # Takes an array of CSS class names. The class names will be applied in
    # sequence to the +tr+ tag of each data row.
    attr_writer :data_row_class
    
    attr_writer :table_id
    
    attr_writer :tbody_id

    # Returns a new CollectionTable object that will operate on the +items+ (any
    # enumerable) and will display a column for each of the specified +columns+.
    # Each column can be specified either as a symbol (:column_name) which will
    # be displayed using the humanized form (Column Name), or it can be
    # specified as a two-element array ([:column_name,'Text for Header'] where
    # the first element identifies the column, and the second element specifies
    # the text to display for that column in the table header. If the second
    # element is +nil+ that column will have a blank header. In either case, the
    # column identifier (the symbol part) should usually match the name of an
    # attribute on the items in the collection. This attribute will be used as
    # the data to display in that column. If you specify an identifier which
    # _does not_ match an attribute of the items in the collection, you _must_
    # specify a #column_modifier for that column, or you will get run-time
    # exceptions.
    def initialize(items, *columns)
      @items = items
      @item_id_attr = :id
      @columns = {}
      @column_order = []
      @column_modifiers = {}
      @column_alignments = {}
      columns.each do |col|
        if col.kind_of? Enumerable
          @column_order << col.first
          @columns[col.first] = (col.last || '')
        else
          @column_order << col
          @columns[col] = Inflector.humanize(col.to_s)
        end
      end
    end

    # Returns the complete HTML for the table based on the options set on the
    # object with a data row for each item in the collection.
    def build_table
      output = "<table #{@table_id.nil? ? '' : "id=\"#{@table_id}\" "}" +
               "class=\"collection_table\">\n"
      output += header_row
      output += "\n  <tbody#{@tbody_id.nil? ? '' : " id=\"#{@tbody_id}\""}>\n"
      output += @items.inject('') { |txt,item| txt + data_row(item) }
      output += "  </tbody>\n"
      output += "</table>\n"
    end

    # Allows you to modify the contents of a column for each of the data rows by
    # specifying the identifier for the column (as specified in the
    # CollectionTable.new method) and providing a block that returns the
    # contents of the cell. The block should take one argument, which is the
    # item in the collection that is being operated on (not just the property
    # that would correspond to the column).
    #
    # call-seq:
    # column_modifier(column) { |item| item.some_property.to_s }
    #
    def column_modifier(column, &block)
      @column_modifiers[column] = block
    end

    # Allows you to set the HTML +align+ attribute on the data cells in the
    # specified column.
    def column_align(column, alignment)
      @column_alignments[column] = alignment
    end

    # See the documentation for the attribute definition
    def data_row_class=(classes) #:nodoc:
      @data_row_class = classes.to_a
    end

    # See the documentation for the attribute definition
    def item_id_attr=(attr_name) #:nodoc:
      @items.each do |i|
        unless i.respond_to?(attr_name)
          raise "Not all items in collection have an #{attr_name.to_s} " +
                "attribute."
        end
      end
      @item_id_attr = attr_name
    end

    private

    # Returns the content for the table header for the specified column.
    def heading_for(column)
      @columns[column] or raise "Heading requested for unknown column"
    end

    # Returns the table data row for +item+
    def data_row(item)
      data_cells = @column_order.inject('') do |txt,col|
        if @column_modifiers[col]
          cell_content = @column_modifiers[col].call(item)
        else
          cell_content = item.send(col).to_s
        end
        if @column_alignments[col]
          td = "<td align=\"#{@column_alignments[col]}\">"
        else
          td = "<td>"
        end
        txt + "      #{td + cell_content}</td>\n"
      end
      "    <tr#{current_row_class}>\n" +
      data_cells + "    </tr>\n"
    end

    # Returns the complete table header row
    def header_row
      header_cells = @column_order.inject('') do |txt,col|
        txt + "      <th>#{heading_for(col)}</th>\n"
      end
      "  <thead>\n    <tr>\n" + header_cells + "    </tr>\n  </thead>"
    end


    # Returns the class HTML attribute for the data table row (if any)
    def current_row_class
      unless @data_row_class.nil?
        @used_data_row_class ||= []
        if current_class = @data_row_class.shift
          @used_data_row_class << current_class
        else
          @data_row_class = @used_data_row_class
          @used_data_row_class = [ current_class = @data_row_class.shift ]
        end
        return " class=\"#{current_class}\""
      end
    end
  end
end
