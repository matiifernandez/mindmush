class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      # authentication fields
      t.string :email, null: false
      t.string :username, null: false
      t.string :password_digest, null: false

      #Stats - default values avoid the setting at creation
      t.integer :total_score, default: 0
      t.integer :games_played, default: 0
      t.integer :games_created, default: 0

      t.timestamps
    end

    # Indexes
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :total_score # for leaderboard queries
  end
end
