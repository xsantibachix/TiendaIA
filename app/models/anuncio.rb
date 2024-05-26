class Anuncio < ApplicationRecord
  belongs_to :usuario
  has_one_attached :image
   
  validates :titulo, :descripcion, :estado, :marca, :modelo, :daño, :image, presence: true
end
