# app/models/access_token.rb
class AccessToken < ApplicationRecord
    belongs_to :user
    belongs_to :client
    belongs_to :authorization_code, optional: true
    
    validates :token, presence: true, uniqueness: true
    validates :expires_at, presence: true
    
    before_validation :generate_token, on: :create
    before_validation :set_expires_at, on: :create
    
    serialize :scopes, coder: JSON
    
    scope :valid, -> { where('expires_at > ?', Time.current) }
    scope :expired, -> { where('expires_at <= ?', Time.current) }
    
    def expired?
      expires_at <= Time.current
    end
    
    def valid?
      !expired?
    end
    
    def has_scope?(scope)
      scopes.include?(scope)
    end
    
    private
    
    def generate_token
      self.token ||= SecureRandom.hex(32)
    end
    
    def set_expires_at
      self.expires_at ||= 1.hour.from_now
    end
  end