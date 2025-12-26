class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      # Mandatory fields
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.text :code, null: false

      # Type and origin
      t.string :game_type, null: false, default: "ai_generated"
      t.text :prompt_used
      t.references :creator, null: true, foreign_key: {to_table: :users}

      # Game Metadata
      t.integer :difficulty, default: 1
      t.integer :duration, default: 30
      t.string :thumbnail_url

      # Survival system
      t.string :status, default: "pending"
      t.datetime :published_at
      t.datetime :expires_at

      # Stats denormalized
      t.integer :play_count, default: 0
      t.integer :unique_players, default: 0
      t.integer :likes_count, default: 0
      t.integer :dislikes_count, default: 0
      t.integer :reports_count, default: 0
      t.float :avg_score, default: 0.0
      t.float :avg_completion_rate, default: 0.0
      t.float :survival_score, default: 0.0

      # Flags
      t.boolean :is_active, default: true
      t.boolean :is_featured, default: false

      t.timestamps
    end

    # Indexes
    add_index :games, :slug, unique: true
    add_index :games, :game_type
    add_index :games, :status
    add_index :games, :survival_score
    add_index :games, :play_count
    add_index :games, :is_featured
    add_index :games, [:status, :expires_at]
  end
end
