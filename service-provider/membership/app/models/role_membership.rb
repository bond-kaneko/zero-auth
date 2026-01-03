# frozen_string_literal: true

class RoleMembership < ApplicationRecord
  self.table_name = "memberships"

  belongs_to :role
  has_one :organization, through: :role

  validates :user_id, presence: true
  validates :role_id, presence: true
  validates :user_id, uniqueness: { scope: :role_id }

  # Scope to get memberships by user
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # Scope to get memberships by organization
  scope :for_organization, lambda { |organization_id|
    joins(:role).where(roles: { organization_id: organization_id })
  }
end
