#!/usr/bin/ruby -w

require 'rubygems'
require 'bundler/setup'

require 'rasem'  # SVG library.  See Gemfile.

# Space between each line.
GRID_SPACING = 22
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

def calculate_board_size(grid_size)
  BOARD_MARGIN * 2 + GRID_SPACING * (grid_size - 1)
end

def calculate_image_size(grid_size)
  calculate_board_size(grid_size) + (IMAGE_MARGIN * 2)
end

def dot(svg, x, y)
  margin = IMAGE_MARGIN + BOARD_MARGIN
  svg.circle(margin + x * GRID_SPACING,
             margin + y * GRID_SPACING,
             DOT_RADIUS,
             fill: 'black', stroke: 'none')
end

def draw_grid_svg(grid_size)
  image_size = calculate_image_size(grid_size)
  image_size_mm = sprintf('%dmm' % image_size)
  view_box = sprintf('0 0 %d %d', image_size, image_size)
  board_size = calculate_board_size(grid_size)
  svg = Rasem::SVGImage.new(image_size_mm, image_size_mm,
                            viewbox: view_box ) do
    # Cut square.
    rectangle(IMAGE_MARGIN, IMAGE_MARGIN, board_size, board_size,
              CORNER_RADIUS,
              fill: 'none', stroke: 'blue')

    # Dots.
    if grid_size == 9
      dot(self, grid_size / 2, grid_size / 2)  # middle.
      dots = [2, grid_size - 2 - 1]
    else
      dots = [3, grid_size / 2, grid_size - 3 - 1]
    end
    dots.each { |x| dots.each { |y| dot(self, x, y) } }

    # Lines.
    (0...grid_size).each do |i|
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

grid_size = ARGV.empty? ? 9 : ARGV[0].to_i

File.open('goban.svg', 'w') do |f|
  svg = draw_grid_svg(grid_size)
  f << svg.output
end
