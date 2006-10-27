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


# = sort_helper.rb - SortHelper for Ruby on Rails
#
# Author: Dave Burt mailto:dave@burt.id.au
#
# Version: 17 Feb 2005
#
# Makes column headings users can click to define how the table is sorted.
#
# == Example
# === View
#
#  <tr>
#    <th><%= link_to_sort_by 'First Name', 'name' %></th>
#    <th><%= link_to_sort_by 'Surname', 'family.name' %></th>
#    <th><%= link_to_sort_by 'Email', 'email' %></th>
#  </tr>
#
# === Controller:
#
#  helper :sort
#
#  def list  # action
#    SortHelper.columns = %w[
#      name
#      family.name
#      email
#    ]
#    SortHelper.default_order = %w[family.name name]
#    @people = Person.find_all.sort do |a, b|
#      SortHelper.sort(a, b, params)
#    end
#  end
#
module SortHelper
  
  # Create a link ('a' tag) back to the current action, but sorting by
  # _sort_column_ before any existing ordering.
  #
  # Example:
  # On an un-sorted page,
  #  <%= link_to_sort_by 'First Name', 'name' %>
  #  <%= link_to_sort_by 'Surname', 'family.name' %>
  #  <%= link_to_sort_by 'Email', 'email' %>
  # could result in:
  #  <a href="/person/list?sort=1">First Name</a>
  #  <a href="/person/list?sort=2">Surname</a>
  #  <a href="/person/list?sort=3">Email</a>
  #
  # If the page was already sorted by first name,
  #  <%= link_to_sort_by 'First Name', 'name' %>
  #  <%= link_to_sort_by 'Surname', 'family.name' %>
  #  <%= link_to_sort_by 'Email', 'email' %>
  # could result in:
  #  <a href="/person/list?sort=-1">First Name</a>
  #  <a href="/person/list?sort=2+1">Surname</a>
  #  <a href="/person/list?sort=3+1">Email</a>
  #
  def link_to_sort_by(link_text, sort_column, path_params)
    
    sort_key = @@sort_keys[sort_column]
    
    sort = (params['sort'] || '').split.map {|param| param.to_i }
    
    if sort[0] && sort[0].abs == sort_key
      sort[0] = -sort[0]
    else
      sort.delete_if {|key| key.abs == sort_key }
      sort.unshift sort_key
    end

    path_params[:sort] = sort.join(' ')
    
    link_to link_text, path_params
  end
  
  # Set the columns that may be used to sort by.
  # You must set this from the controller before you can use
  # +link_to_sort_by+ in a view.
  #
  def self.columns=(column_names)
    # prepend id so that the first sortable column is at index 1
    @@sort_columns = ['id'] + column_names
    @@sort_keys = {}
    @@sort_columns.each_with_index {|obj, i| @@sort_keys[obj] = i }
  end
  
  # Set the columns that are used to sort by default
  #
  def self.default_order=(column_names)
    @@default_columns = column_names.map {|column| @@sort_keys[column] }
  end
  
  # This is a comparison method that returns -1, 0 or 1
  # depending on the passed objects _a_ and _b_, and the sorting
  # priorities defined in _params_. It can be used in blocks
  # given to +Enumerable#sort+.
  #
  # Use it like this:
  #  @people = Person.find_all.sort do |a, b|
  #    SortHelper.sort(a, b, params)
  #  end
  #
  def self.sort(a, b, params)
    if /\d/ === params['sort']
      params['sort'].split
    else
      @@default_columns
    end.each do |column_index|
      column_index = column_index.to_i
      next if column_index.abs >= @@sort_columns.size
      a_col = a
      b_col = b
      @@sort_columns[column_index.abs].split('.').each do |meth|
        a_col = a_col.send(meth) unless a_col.nil?
        b_col = b_col.send(meth) unless b_col.nil?
      end
      reverse = (column_index < 0)
      case a_col && a_col <=> b_col
      when -1
        return reverse ? 1 : -1
      when 1, nil  # nil < anything else
        return reverse ? -1 : 1
      end
    end
    0
  end
end
