#! /opt/local/bin/ruby1.9

require "rexml/document"
require "./yaml2x.rb"

include REXML

def make_style(hash)
  hash.map {|k,v| "#{k}: #{v}"}.join "; "
end

def make_path(arr)
  arr.map {|c| "#{c[0]},#{c[1]}"}.join " "
end

def offset_points(x, y, points)
  points.map {|p| [p[0] + x, p[1] + y]}
end

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."

  CB_WIDTH = 98 # 49mm
  CB_HEIGHT = 50 # 25mm
  CB_HORIZ_GAP = 16 # 8mm
  CB_VERT_GAP = 19 # 9.5mm
  CB_COLUMNS = 3
  CB_ROWS = 5
  POINTS = [[0,4], [18,4], [14,0], [84,0], [80,4], [98,4],
            [98,46], [80,46], [84,50], [14,50], [18,46], [0,46]]

  filename = $*[0]
  outfilename = $*[1]

  matches = /([0-9])_.*/.match(outfilename)
  division = matches[1].to_i

  File.open(outfilename, "w") { |outfile|
    doc = Document.new
    doc << XMLDecl.new("1.0", "utf-8")
    doc << DocType.new("svg", 'PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/PR-SVG-20010719/DTD/svg10.dtd"')
    width = (CB_WIDTH * CB_COLUMNS) + (CB_HORIZ_GAP * (CB_COLUMNS - 1))
    height = (CB_HEIGHT * CB_ROWS) + (CB_VERT_GAP * (CB_ROWS - 1))
    view_box = [-1, -1, width + 1, height + 1]
    svg = doc.add_element "svg", {
      "width" => ((width + 2) / 2).to_s + "mm",
      "height" => ((height + 2) / 2).to_s + "mm",
      "viewBox" => view_box.join(" ")
    }
    svg.add_namespace("http://www.w3.org/2000/svg")
    svg.add_namespace("xlink", "http://www.w3.org/1999/xlink")
    box = svg.add_element "g", {
    }

    for x_offset in (0..(CB_COLUMNS - 1)).map {|xo| xo * (CB_WIDTH + CB_HORIZ_GAP)}
      for y_offset in (0..(CB_ROWS - 1)).map {|yo| yo * (CB_HEIGHT + CB_VERT_GAP)}
        points = offset_points(x_offset, y_offset, POINTS)
        poly_style = make_style({
          "fill" => "#fae88a",
          # "stroke" => "#dcc593",
          "stroke" => "#b7985b", # 183, 152, 91
          "stroke-width" => "0.3",
        })
        poly = box.add_element "polygon", {
          "style" => poly_style,
          "points" => make_path(points)
        }
        text_style = make_style({
          "fill" => "#000000",
          "text-anchor" => "middle",
          "font-family" => "Artisan12",
          "font-style" => "normal",
          "font-weight" => "500" # Normal
        })
        text = box.add_element "text", {
          "font-size" => "7.90222", # What size is this?
          # "font-size" => "5pt", # What size is this?
          "style" => text_style,
          "x" => (49 + x_offset),
          "y" => (21.0489 + y_offset),
        }
        tspan1 = text.add_element "tspan", {
          "x" => (49 + x_offset),
          "y" => (21.0489 + y_offset),
        }
        tspan1.add Text.new("WISE-EYED COURTIER", false)
        tspan2 = text.add_element "tspan", {
          "x" => (49 + x_offset),
          "y" => (30.9267 + y_offset),
        }
        tspan2.add Text.new("METHOD", false)

      end
    end
#     poly
#     add_typed_attr(diagramdata, "background", "color", "#ffffff")
#     layer = svg.add_element "dia:layer", {
#       "name" => "Background",
#       "visible" => "true",
#       "active" => "true"
#     }
#     obj = DiaObject.new("Geometric - Perfect Square",
#                         "3.58226,9.2875",
#                         "3.53226,9.2375;7.34476,13.1738")
#     obj.add_to_layer(layer)

    doc.write(outfile, 1, true)

#     outfile.puts(":doctype: book")
#     outfile.puts(":themedir: ..")
#     outfile.puts(":theme: discordians")
#     outfile.puts(":linkcss:")
#     outfile.puts

#     xml.favorites do 
#       favorites.each do | name, choice |
#         xml.favorite( choice, :item => name )
#       end
#     end


    process_file(filename) { |group_name, charms|
#       outfile.puts("indexterm:[-, Charms, #{division_name}, #{group_name}]")
#       outfile.puts('[options="pgwide"]')
#       pngfilename = File.basename(filename).sub(/\.yml/, ".png")
#       outfile.puts("image::./output/#{pngfilename}[#{group_name} Charm Tree]")
#       outfile.puts

#       outfile.puts("==== " + group_name)
#       outfile.puts

#       charms.each_value { |charm|
#         insert_charm(outfile, group_name, charms, charm)
#       }
    }
  }
end
