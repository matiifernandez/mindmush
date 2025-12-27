class CreateGameTags < ActiveRecord::Migration[7.1]
  def change
    create_table :game_tags do |t|
      t.references :game, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    # A game can't have the same tag more than once
    add_index :game_tags, [:game_id, :tag_id], unique: true
  end
end
