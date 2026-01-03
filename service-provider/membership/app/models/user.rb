# frozen_string_literal: true

class User < ApplicationRecord
  # Explicitly define id_provider_user_id as a regular attribute
  # to prevent Rails from treating it as a foreign key
  attribute :id_provider_user_id, :string

  validates :id_provider_user_id, presence: true, uniqueness: true
  validates :email, presence: true
  validates :name, presence: true, allow_blank: true
end
