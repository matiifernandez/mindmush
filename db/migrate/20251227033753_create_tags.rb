class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :color, default: "#666666"

      t.timestamps
    end

    add_index :tags, :slug, unique: true
    add_index :tags, :name, unique: true
  end
end
