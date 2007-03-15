##
#
# Makes a small pie graph suitable for display at 200px or even smaller.
#
module Gruff
  module Mini

    class SideBar < Gruff::SideBar

      def initialize_ivars
        super
        @hide_legend = true
        @hide_title = true
        @hide_line_numbers = true

        @marker_font_size = 50.0
      end
      
    end
  
  end
end
