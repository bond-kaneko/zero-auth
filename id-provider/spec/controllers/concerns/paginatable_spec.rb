# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Paginatable, type: :concern do
  # Create a dummy class to test the concern
  let(:dummy_class) do
    Class.new do
      include Paginatable
    end
  end

  let(:dummy_instance) { dummy_class.new }

  describe '#validate_pagination_params!' do
    context 'with valid parameters' do
      it 'does not raise error with valid page and per_page' do
        expect { dummy_instance.send(:validate_pagination_params!, page: 1, per_page: 10) }.not_to raise_error
      end

      it 'does not raise error with page=1 and per_page=1' do
        expect { dummy_instance.send(:validate_pagination_params!, page: 1, per_page: 1) }.not_to raise_error
      end

      it 'does not raise error with maximum per_page' do
        expect { dummy_instance.send(:validate_pagination_params!, page: 1, per_page: 1000) }.not_to raise_error
      end

      it 'does not raise error with large page number' do
        expect { dummy_instance.send(:validate_pagination_params!, page: 1000, per_page: 10) }.not_to raise_error
      end
    end

    context 'with invalid page' do
      it 'raises ValidationError when page is 0' do
        expect do
          dummy_instance.send(:validate_pagination_params!, page: 0, per_page: 10)
        end.to raise_error(Paginatable::ValidationError, 'page must be greater than or equal to 1')
      end

      it 'raises ValidationError when page is negative' do
        expect do
          dummy_instance.send(:validate_pagination_params!, page: -1, per_page: 10)
        end.to raise_error(Paginatable::ValidationError, 'page must be greater than or equal to 1')
      end
    end

    context 'with invalid per_page' do
      it 'raises ValidationError when per_page is 0' do
        expect do
          dummy_instance.send(:validate_pagination_params!, page: 1, per_page: 0)
        end.to raise_error(Paginatable::ValidationError, 'per_page must be greater than or equal to 1')
      end

      it 'raises ValidationError when per_page is negative' do
        expect do
          dummy_instance.send(:validate_pagination_params!, page: 1, per_page: -5)
        end.to raise_error(Paginatable::ValidationError, 'per_page must be greater than or equal to 1')
      end

      it 'raises ValidationError when per_page exceeds maximum' do
        expect do
          dummy_instance.send(:validate_pagination_params!, page: 1, per_page: 1001)
        end.to raise_error(Paginatable::ValidationError, 'per_page must be less than or equal to 1000')
      end

      it 'raises ValidationError when per_page is very large' do
        expect do
          dummy_instance.send(:validate_pagination_params!, page: 1, per_page: 5000)
        end.to raise_error(Paginatable::ValidationError, 'per_page must be less than or equal to 1000')
      end
    end
  end
end
