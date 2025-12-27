class Vote < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :game

  # Validations
  validates :value, presence: true, inclusion: {in: [-1, 1]}
  validates :user_id, uniqueness: {scope: :game_id, message: "You have already voted for this game"}

  # Scopes
  scope :likes, -> { where(value: 1) }
  scope :dislikes, -> { where(value: -1) }

  # Callbacks
  after_create :update_game_counters
  after_destroy :update_game_counters

  def update_game_counters
    game.update(
      likes_count: game.votes.likes.count,
      dislikes_count: game.votes.dislikes.count
    )
  end
end
