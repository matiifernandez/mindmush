class LeaderboardsController < ApplicationController
  def index
    subquery = GameSession.completed.by_registered_users
                          .select('user_id, game_id, MAX(score) as max_score')
                          .group(:user_id, :game_id)

    @leaderboard_users = User
      .joins("JOIN (#{subquery.to_sql}) as user_game_scores ON users.id = user_game_scores.user_id")
      .select('users.id, users.username, SUM(user_game_scores.max_score) as total_score')
      .group('users.id, users.username')
      .order('total_score DESC')
      .limit(50) # Display top 50 users on the leaderboard page
  end
end
