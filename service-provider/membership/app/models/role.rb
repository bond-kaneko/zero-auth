# frozen_string_literal: true

class Role < ApplicationRecord
  belongs_to :organization
  has_many :role_memberships, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id }
  validates :permissions, presence: true

  # Get all users with this role
  def users
    role_memberships.pluck(:user_id)
  end
end
