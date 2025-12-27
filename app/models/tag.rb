class Tag < ApplicationRecord
  # Associations
  has_many :game_tags, dependent: :destroy
  has_many :games, through: :game_tags

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # Callbacks
  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if slug.present?
    self.slug = name.to_s.parameterize
  end
end
