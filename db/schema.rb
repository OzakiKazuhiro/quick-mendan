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

ActiveRecord::Schema[8.0].define(version: 2025_06_22_141106) do
  create_table "appointments", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "time_slot_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id", "time_slot_id"], name: "index_appointments_unique", unique: true
    t.index ["student_id"], name: "index_appointments_on_student_id"
    t.index ["time_slot_id"], name: "index_appointments_on_time_slot_id"
    t.index ["time_slot_id"], name: "index_appointments_time_slot_unique", unique: true
  end

  create_table "campus", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_campus_on_name", unique: true
  end

  create_table "interview_records", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_interview_records_on_appointment_id"
  end

  create_table "student_campus_affiliations", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "campus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campus_id"], name: "index_student_campus_affiliations_on_campus_id"
    t.index ["student_id", "campus_id"], name: "index_student_campus_unique", unique: true
    t.index ["student_id"], name: "index_student_campus_affiliations_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "student_number", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "grade"
    t.string "school_name"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assigned_teacher_id"
    t.index ["assigned_teacher_id"], name: "index_students_on_assigned_teacher_id"
    t.index ["reset_password_token"], name: "index_students_on_reset_password_token", unique: true
    t.index ["student_number"], name: "index_students_on_student_number", unique: true
  end

  create_table "teachers", force: :cascade do |t|
    t.string "user_login_name", default: "", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.time "notification_time"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_teachers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_teachers_on_reset_password_token", unique: true
    t.index ["role"], name: "index_teachers_on_role"
    t.index ["user_login_name"], name: "index_teachers_on_user_login_name", unique: true
  end

  create_table "time_slots", force: :cascade do |t|
    t.integer "teacher_id", null: false
    t.integer "campus_id", null: false
    t.date "date", null: false
    t.time "start_time", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campus_id", "date", "start_time"], name: "index_time_slots_on_campus_id_and_date_and_start_time"
    t.index ["campus_id"], name: "index_time_slots_on_campus_id"
    t.index ["date", "start_time"], name: "index_time_slots_on_date_and_start_time"
    t.index ["status"], name: "index_time_slots_on_status"
    t.index ["teacher_id", "date", "start_time", "campus_id"], name: "index_time_slots_on_teacher_date_time_campus", unique: true
    t.index ["teacher_id", "date", "start_time"], name: "index_time_slots_unique", unique: true
    t.index ["teacher_id"], name: "index_time_slots_on_teacher_id"
  end

  add_foreign_key "appointments", "students"
  add_foreign_key "appointments", "time_slots"
  add_foreign_key "interview_records", "appointments"
  add_foreign_key "student_campus_affiliations", "campus", column: "campus_id"
  add_foreign_key "student_campus_affiliations", "students"
  add_foreign_key "students", "teachers", column: "assigned_teacher_id", on_delete: :nullify
  add_foreign_key "time_slots", "campus", column: "campus_id"
  add_foreign_key "time_slots", "teachers"
end
