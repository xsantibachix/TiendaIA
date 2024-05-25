class Usuario < ApplicationRecord
    has_many :anuncios, dependent: :destroy

    validates :nombre, :ciudad, :tlf, presence: true
end
