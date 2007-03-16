module Scruffy::Rasterizers
  # == Scruffy::Rasterizers::BatikRasterizer
  #
  # Author:: Brasten Sager
  # Date:: August 14th, 2006
  #
  # Purely experimental.  Can be used to rasterize SVG graphs with
  # Apache Batik.
  class BatikRasterizer
    # Returns new BatikRasterizer.
    #
    # Options:
    # command:: Command needed to execute Batik. (ie: 'java -classpath {...}')
    # temp_folder:: Folder for storing temporary files being passed between Scruffy and Batik.
    def initialize(options={})
      @command = options[:command]
      @temp_folder = options[:temp_folder]
    end
    
    # Rasterize graph.
    #
    # Options:
    # as:: Image format to generate (PNG, JPG, et al.)
    def rasterize(svg, options={})
      File.open(@temp_folder + '/temp_svg.svg', 'w') { |file|
        file.write(svg)
      }
      
      `#{@command} -d #{@temp_folder} -m image/#{options[:as].downcase} #{@temp_folder}/temp_svg.svg`
      
      image = ""
      File.open(@temp_folder + '/temp_svg.' + options[:as].downcase, 'r') { |file|
        image = file.read
      }
      
      image
    end
  end
end