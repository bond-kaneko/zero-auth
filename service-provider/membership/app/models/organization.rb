# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :roles, dependent: :destroy
  has_many :memberships, through: :roles

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Get all users in this organization (distinct)
  def users
    memberships.select(:user_id).distinct.pluck(:user_id)
  end
end
