class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.string :reason, null: false
      t.text :description
      t.string :status, default: "pending"
      t.references :reviewed_by, null: true, foreign_key: {to_table: :users}
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :reports, [:game_id, :status]
    add_index :reports, :status
  end
end
