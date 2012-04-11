#! /opt/local/bin/ruby1.9

require "rexml/document"
require "./yaml2x.rb"

include REXML

# Although the body text in the Exalted books is 10pt on 12pt, the Charm boxes
# seem to use about 9pt on 11pt.
PT_PER_MM = 25.4/72
FONT_SIZE_IN_MM = (9 * PT_PER_MM)
LINE_HEIGHT_IN_MM = (11 * PT_PER_MM)


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

  CB_WIDTH = 49 # 49mm
  CB_HEIGHT = 25 # 25mm
  CB_HORIZ_GAP = 8 # 8mm
  CB_VERT_GAP = 9.5 # 9.5mm
  CB_COLUMNS = 3
  CB_ROWS = 5
  POINTS = [[0,2], [9,2], [7,0], [42,0], [40,2], [49,2],
            [49,23], [40,23], [42,25], [7,25], [9,23], [0,23]]

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
      "width" => (width + 2).to_s + "mm",
      "height" => (height + 2).to_s + "mm",
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
          "stroke-linejoin" => "round",
          "stroke-width" => "0.3",
        })
        poly = box.add_element "polygon", {
          "style" => poly_style,
          "points" => make_path(points)
        }

        grey_dot_style = make_style({
          "fill" => "grey",
          "stroke" => "silver",
          "stroke-width" => "0.3",
        })
        essence_dot_style = make_style({
          "fill" => "#ffff00",
          "stroke" => "#dcc593",
          "stroke-width" => "0.3",
        })
        attribute_dot_style = make_style({
          "fill" => "#ff0000",
          "stroke" => "#dc9393",
          "stroke-width" => "0.3",
        })
        for d in 0..3
          ed1 = box.add_element "circle", {
            "style" => essence_dot_style,
            "cx" => ((12.5 + (d * 6)) + x_offset),
            "cy" => (2.5 + y_offset),
            "r" => 1.75,
          }
          ad1 = box.add_element "circle", {
            "style" => attribute_dot_style,
            "cx" => ((12.5 + (d * 6)) + x_offset),
            "cy" => ((25 - 2.5) + y_offset),
            "r" => 1.75,
          }
        end
        ed1 = box.add_element "circle", {
          "style" => grey_dot_style,
          "cx" => ((12.5 + (4 * 6)) + x_offset),
          "cy" => (2.5 + y_offset),
          "r" => 1.5,
        }
        ad1 = box.add_element "circle", {
          "style" => grey_dot_style,
          "cx" => ((12.5 + (4 * 6)) + x_offset),
          "cy" => ((25 - 2.5) + y_offset),
          "r" => 1.5,
        }
        text_style = make_style({
          "fill" => "#000000",
          "text-anchor" => "middle",
          "font-family" => "Artisan12",
          "font-style" => "normal",
          "font-weight" => "500" # Normal
        })

        line_count = 2
        total_text_height =
          FONT_SIZE_IN_MM +
          (LINE_HEIGHT_IN_MM * (line_count - 1))
        # We want to centre the lines of text within the Charm box.
        first_line_top = (CB_HEIGHT - total_text_height) / 2
        # We subtract an extra 1mm as a fudge factor, so that the descenders
        # of the last line effectively aren't included in the centering.
        first_line_offset = first_line_top + FONT_SIZE_IN_MM - 1
        line_offset = first_line_offset

        draw_grid = false
        if (draw_grid)
          grid_style = make_style({
            "fill-opacity" => "0",
            "stroke" => "silver",
            "stroke-width" => "0.1",
          })
          grid_style2 = make_style({
            "fill-opacity" => "0",
            "stroke" => "grey",
            "stroke-width" => "0.1",
          })
          for gx in 0..49
            grid1 = box.add_element "line", {
              "style" => (gx % 5 == 0) ? grid_style2 : grid_style,
              "x1" => (gx + x_offset),
              "y1" => (0 + y_offset),
              "x2" => (gx + x_offset),
              "y2" => (CB_HEIGHT + y_offset),
            }
          end
          for gy in 0..25
            grid1 = box.add_element "line", {
              "style" => (gy % 5 == 0) ? grid_style2 : grid_style,
              "x1" => (0 + x_offset),
              "y1" => (gy + y_offset),
              "x2" => (CB_WIDTH + x_offset),
              "y2" => (gy + y_offset),
            }
          end
        end


        text = box.add_element "text", {
          "font-size" => FONT_SIZE_IN_MM,
          "style" => text_style,
          "x" => (24.5 + x_offset),
          "y" => (line_offset + y_offset),
        }
        tspan1 = text.add_element "tspan", {
          "x" => (24.5 + x_offset),
          "y" => (line_offset + y_offset),
        }
        tspan1.add Text.new("Wise-Eyed Courtier", false)
        line_offset += LINE_HEIGHT_IN_MM
        tspan2 = text.add_element "tspan", {
          "x" => (24.5 + x_offset),
          "y" => (line_offset + y_offset),
        }
        tspan2.add Text.new("METHOD", false)

      end
    end

    doc.write(outfile, 1, true)

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
