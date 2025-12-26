class CreateGameSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :game_sessions do |t|
      t.references :user, null: true, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.string :session_token
      t.integer :score, default: 0
      t.integer :duration_played
      t.boolean :completed, default: false
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end

    # Indexes for leaderboard queries
    add_index :game_sessions, [:game_id, :score]
    add_index :game_sessions, [:user_id, :game_id]
    add_index :game_sessions, [:user_id, :score]
    add_index :game_sessions, :created_at
  end
end
