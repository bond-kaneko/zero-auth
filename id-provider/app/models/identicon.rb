# frozen_string_literal: true

# Domain model for generating identicon images from a seed string
class Identicon
  GRID_SIZE = 5
  CELL_SIZE = 80
  IMAGE_SIZE = GRID_SIZE * CELL_SIZE

  attr_reader :seed, :hash, :color, :grids

  def self.generate(seed)
    new(seed)
  end

  def initialize(seed)
    @seed = seed
    @hash = generate_hash
    @color = generate_color
    @grids = Grids.new(hash_bytes, GRID_SIZE)
  end

  def to_svg
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="#{IMAGE_SIZE}" height="#{IMAGE_SIZE}">
        <rect width="#{IMAGE_SIZE}" height="#{IMAGE_SIZE}" fill="#f0f0f0"/>
        #{grids.to_svg(CELL_SIZE, color)}
      </svg>
    SVG
  end

  def to_data_uri
    svg_data = to_svg.gsub(/\s+/, ' ').strip
    encoded = Base64.strict_encode64(svg_data)
    "data:image/svg+xml;base64,#{encoded}"
  end

  private

  def generate_hash
    Digest::MD5.hexdigest(seed)
  end

  def generate_color
    "##{hash[0..5]}"
  end

  def hash_bytes
    hash.scan(/../).map { |h| h.to_i(16) }
  end

  class Grids
    def initialize(hash_bytes, grid_size)
      @grids = generate_pattern(hash_bytes, grid_size)
    end

    def to_svg(cell_size, color)
      @grids.select(&:filled).map do |grid|
        grid.to_svg(cell_size, color)
      end.join("\n    ")
    end

    private

    def generate_pattern(hash_bytes, grid_size)
      grids = []

      (0...grid_size).each do |row|
        (0...grid_size).each do |col|
          # Only calculate for left half + middle
          source_col = col < grid_size / 2.0 ? col : grid_size - 1 - col
          index = (row * (grid_size / 2.0).ceil) + source_col
          filled = hash_bytes[index % hash_bytes.length].even?

          grids << Grid.new(row: row, col: col, filled: filled)
        end
      end

      grids
    end
  end

  class Grid
    attr_reader :row, :col, :filled

    def initialize(row:, col:, filled:)
      @row = row
      @col = col
      @filled = filled
    end

    def to_svg(cell_size, color)
      x = col * cell_size
      y = row * cell_size
      %(<rect x="#{x}" y="#{y}" width="#{cell_size}" height="#{cell_size}" fill="#{color}"/>)
    end
  end
end
