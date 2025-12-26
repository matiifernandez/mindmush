class GameSession < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :game, counter_cache: :play_count
  has_many :game_sessions, dependent: :destroy

  # Validations
  validates :game, presence: true
  validates :score, numericality: {greater_than_or_equal_to: 0}

  # Callbacks
  before_create :set_started_at

  # Scopes for leaderboards
  scope :completed, -> {where(completed: true)}
  scope :by_registered_users, -> {where.not(user_id: nil)}

  scope :leaderboard_for_game, ->(game_id) {
    completed
    .by_registered_users
    .where(game_id: game_id)
    .select('user_id, MAX(score) as best_score')
    .group(:user_id)
    .order('best_score DESC')
    .limit(100)
  }

  private

  def set_started_at
    self.started_at ||= Time.current
  end
end
