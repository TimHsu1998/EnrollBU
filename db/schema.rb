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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180123042544) do

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "college"
    t.string "department"
    t.string "number"
    t.string "section"
    t.string "swapped_name"
    t.string "swapped_college"
    t.string "swapped_department"
    t.string "swapped_number"
    t.string "swapped_section"
    t.string "swapped_lab"
    t.string "add_or_swap"
    t.string "loginemail"
    t.string "loginpassword"
    t.integer "user_id"
    t.boolean "have_lab"
    t.boolean "enrolledin", default: false
    t.string "lab1"
    t.string "lab2"
    t.string "lab3"
    t.string "lab4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
