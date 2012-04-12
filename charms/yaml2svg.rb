#! /opt/local/bin/ruby1.9

require "rexml/document"
require "./yaml2x.rb"

include REXML

# Although the body text in the Exalted books is 10pt on 12pt, the Charm boxes
# seem to use about 9pt on 11pt.
PT_PER_MM = 25.4/72
FONT_SIZE_IN_MM = (9 * PT_PER_MM)
LINE_HEIGHT_IN_MM = (11 * PT_PER_MM)

CB_WIDTH = 49 # 49mm
CB_HEIGHT = 25 # 25mm
CB_HORIZ_GAP = 8 # 8mm
CB_VERT_GAP = 9.5 # 9.5mm
CB_COLUMNS = 3
#CB_ROWS = 5
POINTS = [[0,2], [9,2], [7,0], [42,0], [40,2], [49,2],
          [49,23], [40,23], [42,25], [7,25], [9,23], [0,23]]

def make_style(hash)
  hash.map {|k,v| "#{k}: #{v}"}.join "; "
end

def make_path(arr)
  arr.map {|c| "#{c[0]},#{c[1]}"}.join " "
end

def offset_points(x, y, points)
  points.map {|p| [p[0] + x, p[1] + y]}
end

def draw_dots(box, x_offset, y_offset)
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
end

def draw_grid(box)
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

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."

  filename = $*[0]
  outfilename = $*[1]

  matches = /([0-9])_.*/.match(outfilename)
  division = matches[1].to_i

  File.open(outfilename, "w") { |outfile|

    my_charms = []
    process_file(filename) { |group_name, charms|
      my_charms = charms.values
#       charms.each_value { |charm|
#         p charm.multi_line_name
#       }
    }
    cb_rows = (my_charms.length / CB_COLUMNS.to_f).ceil()

    doc = Document.new
    doc << XMLDecl.new("1.0", "utf-8")
    doc << DocType.new("svg", 'PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/PR-SVG-20010719/DTD/svg10.dtd"')
    width = (CB_WIDTH * CB_COLUMNS) + (CB_HORIZ_GAP * (CB_COLUMNS - 1))
    height = (CB_HEIGHT * cb_rows) + (CB_VERT_GAP * (cb_rows - 1))
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

    charm_index = 0
    for x_offset in (0..(CB_COLUMNS - 1)).map {|xo| xo * (CB_WIDTH + CB_HORIZ_GAP)}
      for y_offset in (0..(cb_rows - 1)).map {|yo| yo * (CB_HEIGHT + CB_VERT_GAP)}
        charm = my_charms[charm_index]
        p charm
        break if charm == nil

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

        draw_dots(box, x_offset, y_offset)

        if (false)
          draw_grid(box)
        end

        text_style = make_style({
          "fill" => "#000000",
          "text-anchor" => "middle",
          "font-family" => "Artisan12",
          "font-style" => "normal",
          "font-weight" => "500" # Normal
        })

        text_lines = charm.multi_line_name

        line_count = text_lines.length
        total_text_height =
          FONT_SIZE_IN_MM +
          (LINE_HEIGHT_IN_MM * (line_count - 1))
        # We want to centre the lines of text within the Charm box.
        first_line_top = (CB_HEIGHT - total_text_height) / 2
        # We subtract an extra 1mm as a fudge factor, so that the descenders
        # of the last line effectively aren't included in the centering.
        first_line_offset = first_line_top + FONT_SIZE_IN_MM - 1
        line_offset = first_line_offset

        text = box.add_element "text", {
          "font-size" => FONT_SIZE_IN_MM,
          "style" => text_style,
          "x" => (24.5 + x_offset),
          "y" => (line_offset + y_offset),
        }
        for line in text_lines
          tspan = text.add_element "tspan", {
            "x" => (24.5 + x_offset),
            "y" => (line_offset + y_offset),
          }
          tspan.add Text.new(line, false)
          line_offset += LINE_HEIGHT_IN_MM
        end
        charm_index += 1
      end
    end

    doc.write(outfile, 1, true)
  }
end
