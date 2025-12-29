# app/models/authorization_code.rb
class AuthorizationCode < ApplicationRecord
    belongs_to :user
    belongs_to :client
    
    validates :code, presence: true, uniqueness: true
    validates :redirect_uri, presence: true
    validates :expires_at, presence: true
    
    before_validation :generate_code, on: :create
    before_validation :set_expires_at, on: :create
    
    serialize :scopes, Array
    serialize :nonce, String
    
    scope :valid, -> { where(used: false).where('expires_at > ?', Time.current) }
    scope :expired, -> { where('expires_at <= ?', Time.current) }
    
    def expired?
      expires_at <= Time.current
    end
    
    def valid?
      !used && !expired?
    end
    
    def use!
      update!(used: true, used_at: Time.current)
    end
    
    private
    
    def generate_code
      self.code ||= SecureRandom.hex(32)
    end
    
    def set_expires_at
      self.expires_at ||= 10.minutes.from_now
    end
  end