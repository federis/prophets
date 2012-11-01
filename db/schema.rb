# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121101155243) do

  create_table "answers", :force => true do |t|
    t.string   "content"
    t.integer  "question_id"
    t.integer  "user_id"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.decimal  "initial_probability",  :precision => 6,  :scale => 5, :default => 0.0
    t.decimal  "current_probability",  :precision => 6,  :scale => 5
    t.boolean  "correct"
    t.decimal  "bet_total",            :precision => 15, :scale => 2, :default => 0.0
    t.datetime "judged_at"
    t.integer  "judge_id"
    t.datetime "correctness_known_at"
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"
  add_index "answers", ["user_id"], :name => "index_answers_on_user_id"

  create_table "bets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "answer_id"
    t.decimal  "amount",         :precision => 12, :scale => 2
    t.decimal  "probability",    :precision => 6,  :scale => 5
    t.decimal  "bonus",          :precision => 7,  :scale => 5
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.datetime "invalidated_at"
    t.decimal  "payout",         :precision => 15, :scale => 2
    t.integer  "league_id"
  end

  add_index "bets", ["answer_id"], :name => "index_bets_on_answer_id"
  add_index "bets", ["user_id"], :name => "index_bets_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "leagues", :force => true do |t|
    t.string   "name"
    t.boolean  "priv",                                           :default => false
    t.integer  "user_id"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.decimal  "max_bet",         :precision => 12, :scale => 2
    t.decimal  "initial_balance", :precision => 12, :scale => 2
  end

  add_index "leagues", ["user_id"], :name => "index_leagues_on_user_id"

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "league_id"
    t.string   "name"
    t.integer  "role",                                      :default => 2
    t.decimal  "balance",    :precision => 15, :scale => 2
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

  add_index "memberships", ["league_id"], :name => "index_league_memberships_on_league_id"
  add_index "memberships", ["user_id"], :name => "index_league_memberships_on_user_id"

  create_table "questions", :force => true do |t|
    t.string   "content"
    t.text     "desc"
    t.integer  "league_id"
    t.integer  "user_id"
    t.integer  "approver_id"
    t.datetime "approved_at"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.decimal  "initial_pool",      :precision => 15, :scale => 2
    t.datetime "betting_closes_at"
  end

  add_index "questions", ["approver_id"], :name => "index_questions_on_approver_id"
  add_index "questions", ["league_id"], :name => "index_questions_on_league_id"
  add_index "questions", ["user_id"], :name => "index_questions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "name"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "fb_uid"
    t.string   "fb_token"
    t.datetime "fb_token_expires_at"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
