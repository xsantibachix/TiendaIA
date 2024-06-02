class Usuario < ApplicationRecord
    has_secure_password
  
    has_many :anuncios, dependent: :destroy
  
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }, if: :password_digest_changed?
    validates :password_confirmation, presence: true, if: :password_digest_changed?
  
    validates :nombre, presence: true
    validates :ciudad, presence: true
    validates :tlf, presence: true
  end
  