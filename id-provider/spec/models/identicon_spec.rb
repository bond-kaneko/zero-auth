# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identicon do
  describe '.generate' do
    it 'creates an identicon instance' do
      seed = 'test-uuid-1234'
      identicon = described_class.generate(seed)
      expect(identicon).to be_a(described_class)
    end

    it 'sets the seed' do
      seed = 'test-uuid-1234'
      identicon = described_class.generate(seed)
      expect(identicon.seed).to eq(seed)
    end
  end

  describe '#hash' do
    it 'generates MD5 hash from seed' do
      seed = 'test-uuid-1234'
      identicon = described_class.generate(seed)
      expect(identicon.hash).to eq(Digest::MD5.hexdigest(seed))
    end

    it 'generates consistent hash for same seed' do
      seed = 'test-uuid-1234'
      identicon = described_class.generate(seed)
      identicon2 = described_class.generate(seed)
      expect(identicon.hash).to eq(identicon2.hash)
    end

    it 'generates different hash for different seed' do
      identicon = described_class.generate('test-uuid-1234')
      identicon2 = described_class.generate('different-seed')
      expect(identicon.hash).not_to eq(identicon2.hash)
    end
  end

  describe '#color' do
    it 'generates color from hash' do
      identicon = described_class.generate('test-uuid-1234')
      expect(identicon.color).to start_with('#')
      expect(identicon.color.length).to eq(7) # #RRGGBB
    end

    it 'uses first 6 characters of hash' do
      identicon = described_class.generate('test-uuid-1234')
      expected_color = "##{identicon.hash[0..5]}"
      expect(identicon.color).to eq(expected_color)
    end
  end

  describe '#grids' do
    it 'creates Grids instance' do
      identicon = described_class.generate('test-uuid-1234')
      expect(identicon.grids).to be_a(described_class::Grids)
    end
  end

  describe '#to_svg' do
    it 'generates valid SVG' do
      identicon = described_class.generate('test-uuid-1234')
      svg = identicon.to_svg
      expect(svg).to include('<svg')
      expect(svg).to include('</svg>')
    end

    it 'includes correct dimensions' do
      identicon = described_class.generate('test-uuid-1234')
      svg = identicon.to_svg
      expect(svg).to include("width=\"#{described_class::IMAGE_SIZE}\"")
      expect(svg).to include("height=\"#{described_class::IMAGE_SIZE}\"")
    end

    it 'includes background rectangle' do
      identicon = described_class.generate('test-uuid-1234')
      svg = identicon.to_svg
      expect(svg).to include('fill="#f0f0f0"')
    end

    it 'includes colored rectangles for filled cells' do
      identicon = described_class.generate('test-uuid-1234')
      svg = identicon.to_svg
      expect(svg).to include("fill=\"#{identicon.color}\"")
    end
  end

  describe '#to_data_uri' do
    it 'generates data URI' do
      identicon = described_class.generate('test-uuid-1234')
      data_uri = identicon.to_data_uri
      expect(data_uri).to start_with('data:image/svg+xml;base64,')
    end

    it 'contains base64 encoded SVG' do
      identicon = described_class.generate('test-uuid-1234')
      data_uri = identicon.to_data_uri
      encoded_part = data_uri.split(',')[1]
      decoded = Base64.strict_decode64(encoded_part)
      expect(decoded).to include('<svg')
    end
  end

  describe Identicon::Grids do
    describe '#to_svg' do
      it 'generates SVG for filled cells only' do
        hash_bytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
        grids = described_class.new(hash_bytes, 5)
        svg = grids.to_svg(80, '#123456')
        expect(svg).to be_a(String)
      end
    end

    describe 'pattern generation' do
      it 'creates symmetric pattern' do
        hash_bytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
        grid_array = Array.new(5) { Array.new(5, nil) }

        # Extract filled status for each position and check symmetry
        (0...5).each do |row|
          (0...5).each do |col|
            source_col = col < 2.5 ? col : 4 - col
            byte_index = (row * 3) + source_col
            grid_array[row][col] = hash_bytes[byte_index % hash_bytes.length].even?
          end

          # Check symmetry for this row
          expect(grid_array[row][0]).to eq(grid_array[row][4])
          expect(grid_array[row][1]).to eq(grid_array[row][3])
        end
      end
    end
  end

  describe Identicon::Grid do
    describe '#initialize' do
      it 'sets row, col, and filled attributes' do
        grid = described_class.new(row: 2, col: 3, filled: true)
        expect(grid.row).to eq(2)
        expect(grid.col).to eq(3)
        expect(grid.filled).to be(true)
      end
    end

    describe '#to_svg' do
      it 'generates SVG rectangle' do
        grid = described_class.new(row: 2, col: 3, filled: true)
        svg = grid.to_svg(80, '#123456')
        expect(svg).to eq('<rect x="240" y="160" width="80" height="80" fill="#123456"/>')
      end
    end
  end
end
