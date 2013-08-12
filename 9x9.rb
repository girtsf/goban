#!/usr/bin/ruby -w

require 'rubygems'
require 'bundler/setup'

require 'rasem'  # SVG library.  See Gemfile.

# Space between each line.
GRID_SPACING = 22
# Number of lines.
LINE_COUNT = 9
# Space between the "cut" square and lines.
BOARD_MARGIN = 25
# Space between the "cut" square and outer square.
OUTER_BOARD_MARGIN = 24
# Space around the "cut" square.
IMAGE_MARGIN = 10
# Corner radius for the "cut" square.
CORNER_RADIUS = 3
# Radius for the dots.
DOT_RADIUS = 3

def calculate_board_size
  BOARD_MARGIN * 2 + GRID_SPACING * (LINE_COUNT - 1)
end

def calculate_image_size
  calculate_board_size() + (IMAGE_MARGIN * 2)
end

def dot(svg, x, y)
  margin = IMAGE_MARGIN + BOARD_MARGIN
  svg.circle(margin + x * GRID_SPACING,
             margin + y * GRID_SPACING,
             DOT_RADIUS,
             fill: 'black', stroke: 'none')
end

def draw_grid_svg
  image_size = calculate_image_size
  image_size_mm = sprintf('%dmm' % image_size)
  view_box = sprintf('0 0 %d %d', image_size, image_size)
  board_size = calculate_board_size
  svg = Rasem::SVGImage.new(image_size_mm, image_size_mm,
                            viewbox: view_box ) do
    # Cut square.
    rectangle(IMAGE_MARGIN, IMAGE_MARGIN, board_size, board_size,
              CORNER_RADIUS,
              fill: 'none', stroke: 'blue')

    # Dots.
    dot(self, LINE_COUNT / 2, LINE_COUNT / 2)
    [2, LINE_COUNT - 2 - 1].each do |x|
      [2, LINE_COUNT - 2 - 1].each do |y|
        dot(self, x, y)
      end
    end

    # Lines.
    (0...LINE_COUNT).each do |i|
      a = IMAGE_MARGIN + BOARD_MARGIN
      b = a + (i * GRID_SPACING)
      line(b, a, b, image_size - a)
      line(a, b, image_size - a, b)
    end

    # Outer rectangle.
    offset = IMAGE_MARGIN + OUTER_BOARD_MARGIN
    rectangle(offset, offset,
              image_size - (2 * offset),
              image_size - (2 * offset),
              fill: 'none', stroke: 'black')

  end
  svg
end

File.open('9x9.svg', 'w') do |f|
  f << draw_grid_svg.output
end
