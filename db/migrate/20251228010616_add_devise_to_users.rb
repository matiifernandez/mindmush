# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      ## Database authenticatable
      # Email already exists, don't need to add it again
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
    end

    # Index for reset_password_token
    add_index :users, :reset_password_token, unique: true

    # Remove password_digest (no longer used, Devise uses encrypted_password)
    remove_column :users, :password_digest, :string
  end
end
