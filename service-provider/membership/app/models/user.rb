# frozen_string_literal: true

class User < ApplicationRecord
  validates :user_id, presence: true, uniqueness: true
  validates :email, presence: true
  validates :name, presence: true
end
