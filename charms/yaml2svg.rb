#! /opt/local/bin/ruby1.9

require "rexml/document"
require "./yaml2x.rb"

include REXML

ESSENCE_NAME = "Ess"

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
OUTLINE_POINTS = [
  [0,2], [9,2], [7,0], [42,0], [40,2], [49,2],
  [49,23], [40,23], [42,25], [7,25], [9,23], [0,23]
]

def make_style(hash)
  hash.map {|k,v| "#{k}: #{v}"}.join "; "
end

def make_path(arr)
  arr.map {|c| "#{c[0]},#{c[1]}"}.join " "
end

def offset_points(x, y, points)
  points.map {|p| [p[0] + x, p[1] + y]}
end

def draw_outline(box, x, y)
  points = offset_points(x, y, OUTLINE_POINTS)
  poly_style = make_style({
      "fill" => "#fae88a",
      "stroke" => "#b7985b",
      "stroke-linejoin" => "round",
      "stroke-width" => "0.3",
    })
  poly = box.add_element "polygon", {
    "style" => poly_style,
    "points" => make_path(points)
  }
end

FIRST_DOT_X = 12.5 # mm
DOT_SPACING = 6 # mm
DOT_INSET = 2.5 # mm

def draw_dot(
    box,
    x,
    y,
    is_top,
    index,
    is_filled,
    filled_style,
    empty_style
    )
  style = is_filled ? filled_style : empty_style
  y_pos = (is_top ? DOT_INSET : (CB_HEIGHT - DOT_INSET)) + y
  r = is_filled ? 1.75 : 1.5
  box.add_element "circle", {
    "style" => style,
    "cx" => FIRST_DOT_X + (index * DOT_SPACING) + x,
    "cy" => y_pos,
    "r" => r,
  }
end

EMPTY_DOT_STYLE = make_style(
  "fill" => "grey",
  "stroke" => "silver",
  "stroke-width" => "0.3",
  )
ESSENCE_DOT_STYLE = make_style(
  "fill" => "#ffff00",
  "stroke" => "#dcc593",
  "stroke-width" => "0.3",
  )
GROUP_DOT_STYLE = make_style(
  "fill" => "#ff0000",
  "stroke" => "#dc9393",
  "stroke-width" => "0.3",
  )

def draw_dots(box, x, y, essence_rating, group_rating)
  for d in 0..4
    draw_dot(
      box, x, y,
      true, d, d < essence_rating,
      ESSENCE_DOT_STYLE, EMPTY_DOT_STYLE
      )
    draw_dot(
      box, x, y,
      false, d, d < group_rating,
      GROUP_DOT_STYLE, EMPTY_DOT_STYLE
      )
  end
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
      "x1" => (gx + x),
      "y1" => (0 + y),
      "x2" => (gx + x),
      "y2" => (CB_HEIGHT + y),
    }
  end
  for gy in 0..25
    grid1 = box.add_element "line", {
      "style" => (gy % 5 == 0) ? grid_style2 : grid_style,
      "x1" => (0 + x),
      "y1" => (gy + y),
      "x2" => (CB_WIDTH + x),
      "y2" => (gy + y),
    }
  end
end

TEXT_STYLE = make_style(
  "fill" => "#000000",
  "text-anchor" => "middle",
  "font-family" => "Artisan12",
  "font-style" => "normal",
  "font-weight" => "500" # Normal
  )

def draw_text(box, x, y, text_lines)
  line_count = text_lines.length
  total_text_height = FONT_SIZE_IN_MM + (LINE_HEIGHT_IN_MM * (line_count - 1))
  # We want to centre the lines of text within the Charm box.
  first_line_top = (CB_HEIGHT - total_text_height) / 2
  # We subtract an extra 1mm as a fudge factor, so that the descenders
  # of the last line effectively aren't included in the centering.
  first_line_offset = first_line_top + FONT_SIZE_IN_MM - 1
  line_offset = first_line_offset

  text = box.add_element "text", {
    "font-size" => FONT_SIZE_IN_MM,
    "style" => TEXT_STYLE,
    "x" => (24.5 + x),
    "y" => (line_offset + y),
  }
  for line in text_lines
    tspan = text.add_element "tspan", {
      "x" => (24.5 + x),
      "y" => (line_offset + y),
    }
    tspan.add Text.new(line, false)
    line_offset += LINE_HEIGHT_IN_MM
  end

end

def draw_charm(box, x, y, charm)
  draw_outline(box, x, y)

  if (charm.mins != nil)
    essence_dots = charm.mins[ESSENCE_NAME]
    group_dots = charm.mins[charm.group]
    draw_dots(box, x, y, essence_dots, group_dots)
  end

  if (false)
    draw_grid(box)
  end

  draw_text(box, x, y, charm.multi_line_name)
end

def draw_layout(charms, layout, outfilename)
  File.open(outfilename, "w") { |outfile|
    raw_charms = charms.values
    cb_rows = layout.grid.length

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

    for row in 0..(cb_rows - 1)
      # TODO 2012-04-13 HUGR: Check for >3 columns
      for col in 0..2
        charm = charms[layout.grid[row][col]]
        next if charm == nil

        x = col * (CB_WIDTH + CB_HORIZ_GAP)
        y = row * (CB_HEIGHT + CB_VERT_GAP)
        draw_charm(box, x, y, charm)
      end
    end

    doc.write(outfile, 1, true)
  }
end

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."

  filename = $*[0]
  outfilename = $*[1]

  matches = /([0-9])_.*/.match(outfilename)
  division = matches[1].to_i

  process_file(filename) { |group_name, charms, layouts|
    p layouts
    if layouts.length > 1
      $stderr << "Can only handle 1 layout for now"
      exit(-1)
    end

    draw_layout(charms, layouts[0], outfilename)
  }
end
