# frozen_string_literal: true

class RoleMembership < ApplicationRecord
  self.table_name = "memberships"

  belongs_to :role
  belongs_to :user, primary_key: :id_provider_user_id, foreign_key: :user_id
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

  # Scope to search memberships by keyword (user name, email, or role name)
  scope :search_by_keyword, lambda { |keyword|
    return all if keyword.blank?

    sanitized_keyword = "%#{sanitize_sql_like(keyword)}%"
    left_joins(:role, :user)
      .where(
        "users.name LIKE ? OR users.email LIKE ? OR roles.name LIKE ?",
        sanitized_keyword,
        sanitized_keyword,
        sanitized_keyword
      )
  }
end
