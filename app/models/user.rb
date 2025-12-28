class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  # Associations
  has_many :created_games, class_name: "Game", foreign_key: "creator_id", dependent: :nullify
  has_many :game_sessions, dependent: :nullify
  has_many :votes, dependent: :destroy
  has_many :reports, dependent: :destroy

  # Validations (email is validated by Devise :validatable)
  validates :username, presence: true,
                      uniqueness: { case_sensitive: false },
                      length: { minimum: 3, maximum: 20 },
                      format: { with: /\A[a-zA-Z0-9_]+\z/,
                                message: "only allows letters, numbers, and underscores" }
end
