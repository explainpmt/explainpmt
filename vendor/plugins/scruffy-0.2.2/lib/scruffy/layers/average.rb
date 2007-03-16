module Scruffy::Layers
  # ==Scruffy::Layers::Average
  #
  # Author:: Brasten Sager
  # Date:: August 7th, 2006
  #
  # An 'average' graph.  This graph iterates through all the layers and averages
  # all the data at each point, then draws a thick, translucent, shadowy line graph
  # indicating the average values.
  #
  # This only looks decent in SVG mode.  ImageMagick doesn't retain the transparency
  # for some reason, creating a massive black line.  Any help resolving this would
  # be useful.
  class Average < Base
    
    # Returns new Average graph.
    def initialize(options = {})
      # Set self's relevant_data to false.  Otherwise we get stuck in a
      # recursive loop.
      super(options.merge({:relevant_data => false}))
    end
    
    # Render average graph.
    def draw(svg, coords, options = {})
      svg.polyline( :points => coords.join(' '), :fill => 'none', :stroke => 'black',
                    'stroke-width' => relative(5), 'opacity' => '0.4')
    end

    protected
      # Override default generate_coordinates method to iterate through the layers and
      # generate coordinates based on the average data points.
      def generate_coordinates(options = {})
        key_layer = points.find { |layer| layer.relevant_data? }
      
        options[:point_distance] = width / (key_layer.points.size - 1).to_f

        coords = []

        key_layer.points.each_with_index do |layer, idx|
          sum, objects = points.inject([0, 0]) do |arr, elem|
            if elem.relevant_data?
              arr[0] += elem.points[idx]
              arr[1] += 1
            end
            arr
          end

          average = sum / objects.to_f

          x_coord = options[:point_distance] * idx

          relative_percent = ((average == min_value) ? 0 : ((average - min_value) / (max_value - min_value).to_f))
          y_coord = (height - (height * relative_percent))

          coords << [x_coord, y_coord].join(',')
        end

        return coords
      end
  
  end
end