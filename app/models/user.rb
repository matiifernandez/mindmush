class User < ApplicationRecord
  # Authentication
  has_secure_password
  has_many :game_sessions, dependent: :nullify
  has_many :reports, dependent: :destroy

  # Associations
  has_many :created_games, class_name: "Game", foreign_key: "creator_id", dependent: :nullify
  has_many :votes, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :username, presence: true, uniqueness: {case_sensitive: false}, length: {minimum: 3, maximum: 20}, format: {with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores"}
end
