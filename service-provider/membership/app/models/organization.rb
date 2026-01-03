# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :roles, dependent: :destroy
  has_many :role_memberships, through: :roles

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Get all users in this organization (distinct)
  def users
    role_memberships.select(:user_id).distinct.pluck(:user_id)
  end
end
