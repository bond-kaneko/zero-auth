# app/models/refresh_token.rb
class RefreshToken < ApplicationRecord
    belongs_to :user
    belongs_to :client
    belongs_to :access_token, optional: true
    
    validates :token, presence: true, uniqueness: true
    validates :expires_at, presence: true
    
    before_validation :generate_token, on: :create
    before_validation :set_expires_at, on: :create
    
    scope :valid, -> { where(revoked: false).where('expires_at > ?', Time.current) }
    scope :expired, -> { where('expires_at <= ?', Time.current) }
    scope :revoked, -> { where(revoked: true) }
    
    def expired?
      expires_at <= Time.current
    end
    
    def revoke!
      update!(revoked: true, revoked_at: Time.current)
    end
    
    private
    
    def generate_token
      self.token ||= SecureRandom.hex(32)
    end
    
    def set_expires_at
      self.expires_at ||= 30.days.from_now
    end
  end