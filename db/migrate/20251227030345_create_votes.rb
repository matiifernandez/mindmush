class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.integer :value

      t.timestamps
    end

    # One user can vote only once per game
    add_index :votes, [:user_id, :game_id], unique: true
    # Likes/Dislikes count
    add_index :votes, [:game_id, :value]
  end
end
