# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_12_27_031752) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_sessions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "game_id", null: false
    t.string "session_token"
    t.integer "score", default: 0
    t.integer "duration_played"
    t.boolean "completed", default: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_game_sessions_on_created_at"
    t.index ["game_id", "score"], name: "index_game_sessions_on_game_id_and_score"
    t.index ["game_id"], name: "index_game_sessions_on_game_id"
    t.index ["user_id", "game_id"], name: "index_game_sessions_on_user_id_and_game_id"
    t.index ["user_id", "score"], name: "index_game_sessions_on_user_id_and_score"
    t.index ["user_id"], name: "index_game_sessions_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "description"
    t.text "code", null: false
    t.string "game_type", default: "ai_generated", null: false
    t.text "prompt_used"
    t.bigint "creator_id"
    t.integer "difficulty", default: 1
    t.integer "duration", default: 30
    t.string "thumbnail_url"
    t.string "status", default: "pending"
    t.datetime "published_at"
    t.datetime "expires_at"
    t.integer "play_count", default: 0
    t.integer "unique_players", default: 0
    t.integer "likes_count", default: 0
    t.integer "dislikes_count", default: 0
    t.integer "reports_count", default: 0
    t.float "avg_score", default: 0.0
    t.float "avg_completion_rate", default: 0.0
    t.float "survival_score", default: 0.0
    t.boolean "is_active", default: true
    t.boolean "is_featured", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_games_on_creator_id"
    t.index ["game_type"], name: "index_games_on_game_type"
    t.index ["is_featured"], name: "index_games_on_is_featured"
    t.index ["play_count"], name: "index_games_on_play_count"
    t.index ["slug"], name: "index_games_on_slug", unique: true
    t.index ["status", "expires_at"], name: "index_games_on_status_and_expires_at"
    t.index ["status"], name: "index_games_on_status"
    t.index ["survival_score"], name: "index_games_on_survival_score"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.string "reason", null: false
    t.text "description"
    t.string "status", default: "pending"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "status"], name: "index_reports_on_game_id_and_status"
    t.index ["game_id"], name: "index_reports_on_game_id"
    t.index ["reviewed_by_id"], name: "index_reports_on_reviewed_by_id"
    t.index ["status"], name: "index_reports_on_status"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "username", null: false
    t.string "password_digest", null: false
    t.integer "total_score", default: 0
    t.integer "games_played", default: 0
    t.integer "games_created", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["total_score"], name: "index_users_on_total_score"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "value"], name: "index_votes_on_game_id_and_value"
    t.index ["game_id"], name: "index_votes_on_game_id"
    t.index ["user_id", "game_id"], name: "index_votes_on_user_id_and_game_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "game_sessions", "games"
  add_foreign_key "game_sessions", "users"
  add_foreign_key "games", "users", column: "creator_id"
  add_foreign_key "reports", "games"
  add_foreign_key "reports", "users"
  add_foreign_key "reports", "users", column: "reviewed_by_id"
  add_foreign_key "votes", "games"
  add_foreign_key "votes", "users"
end
