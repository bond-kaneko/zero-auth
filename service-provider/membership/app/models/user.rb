# frozen_string_literal: true

class User < ApplicationRecord
  self.primary_key = "id_provider_user_id"

  validates :id_provider_user_id, presence: true, uniqueness: true
  validates :email, presence: true
  validates :name, presence: true, allow_blank: true
end
