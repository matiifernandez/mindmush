class Game < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: "User", optional: true
  has_many :votes, dependent: :destroy

  # Enums - convert string fields to enums for better handling
  enum :game_type, {
    predefined: "predefined",
    ai_generated: "ai_generated",
  }, prefix: true

  enum :status, {
    pending: "pending",
    trial: "trial",
    approved: "approved",
    rejected: "rejected",
    archived: "archived",
  }, prefix: true

  # Validations
  validates :title, presence: true, length: {maximum: 100}
  validates :slug, presence: true, uniqueness: true
  validates :code, presence: true
  validates :game_type, presence: true
  validates :difficulty, inclusion: {in: 1..5}
  validates :duration, numericality: {greater_than: 0, less_than_or_equal_to: 300}

  # Callbacks
  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if slug.present?

    base_slug = title.to_s.parameterize
    self.slug = "#{base_slug}-#{SecureRandom.hex(4)}"
  end
end
