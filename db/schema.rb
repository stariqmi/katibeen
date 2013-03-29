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

ActiveRecord::Schema.define(:version => 20130329070841) do

  create_table "outgoing_day_prayers", :force => true do |t|
    t.string   "url"
    t.datetime "time"
    t.string   "weekday"
    t.integer  "fajr"
    t.integer  "zuhr"
    t.integer  "asr"
    t.integer  "maghrib"
    t.integer  "isha"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "status"
    t.integer  "times_updated"
  end

  create_table "potential_users", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "url"
    t.string   "timezone"
  end

  add_index "potential_users", ["email"], :name => "index_potential_users_on_email", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "url"
    t.string   "timezone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.float    "average"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
