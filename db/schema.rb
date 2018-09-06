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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180906151531) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"

  create_table "contact_types", force: :cascade do |t|
    t.string   "name"
    t.boolean  "inactive",   default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "donation_types", force: :cascade do |t|
    t.string   "name"
    t.boolean  "non_monetary", default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "inactive",     default: false, null: false
  end

  create_table "donations", force: :cascade do |t|
    t.date     "date_received"
    t.decimal  "value"
    t.string   "ref_no"
    t.string   "item"
    t.boolean  "anonymous",        default: false, null: false
    t.string   "in_honor_of"
    t.string   "designation"
    t.string   "notes"
    t.boolean  "receipt_sent",     default: false, null: false
    t.integer  "volunteer_id"
    t.integer  "organization_id"
    t.integer  "donation_type_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "old_id"
  end

  add_index "donations", ["donation_type_id"], name: "index_donations_on_donation_type_id", using: :btree
  add_index "donations", ["organization_id"], name: "index_donations_on_organization_id", using: :btree
  add_index "donations", ["volunteer_id"], name: "index_donations_on_volunteer_id", using: :btree

  create_table "interest_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interests", force: :cascade do |t|
    t.string   "name"
    t.integer  "interest_category_id"
    t.boolean  "highlight"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "inactive",               default: false, null: false
    t.boolean  "include_on_application", default: false
  end

  add_index "interests", ["interest_category_id"], name: "index_interests_on_interest_category_id", using: :btree

  create_table "organization_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "inactive",   default: false, null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.integer  "organization_type_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "email"
    t.string   "phone"
    t.string   "notes"
    t.string   "contact_name"
    t.string   "old_id"
    t.boolean  "remove_from_mailing_list", default: false, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "organizations", ["organization_type_id"], name: "index_organizations_on_organization_type_id", using: :btree

  create_table "pending_volunteer_interests", force: :cascade do |t|
    t.integer  "interest_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "pending_volunteer_id"
  end

  add_index "pending_volunteer_interests", ["interest_id"], name: "index_pending_volunteer_interests_on_interest_id", using: :btree

  create_table "pending_volunteers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "email"
    t.string   "city"
    t.boolean  "resolved",     default: false, null: false
    t.string   "xml"
    t.string   "raw"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "address"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.string   "notes"
    t.integer  "volunteer_id"
    t.string   "home_phone"
    t.string   "work_phone"
    t.string   "mobile_phone"
  end

  add_index "pending_volunteers", ["volunteer_id"], name: "index_pending_volunteers_on_volunteer_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.boolean  "inactive",    default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "old_id"
    t.string   "description"
  end

  add_index "projects", ["old_id"], name: "index_projects_on_old_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "name"
    t.string   "site_title"
    t.string   "org_title"
    t.string   "org_short_title"
    t.string   "org_site"
    t.string   "old_system_site"
    t.string   "old_system_name"
    t.boolean  "no_pagination"
    t.integer  "records_per_page"
    t.integer  "min_password_length"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "adult_waiver_text"
    t.string   "minor_waiver_text"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",                  default: false
    t.boolean  "all_donations",          default: false, null: false
    t.boolean  "non_monetary_donations", default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "volunteer_categories", force: :cascade do |t|
    t.string   "name"
    t.boolean  "inactive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "volunteer_category_volunteers", force: :cascade do |t|
    t.integer  "volunteer_id"
    t.integer  "volunteer_category_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "volunteer_category_volunteers", ["volunteer_category_id"], name: "index_volunteer_category_volunteers_on_volunteer_category_id", using: :btree
  add_index "volunteer_category_volunteers", ["volunteer_id"], name: "index_volunteer_category_volunteers_on_volunteer_id", using: :btree

  create_table "volunteer_interests", force: :cascade do |t|
    t.integer  "volunteer_id"
    t.integer  "interest_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "volunteer_interests", ["interest_id"], name: "index_volunteer_interests_on_interest_id", using: :btree
  add_index "volunteer_interests", ["volunteer_id"], name: "index_volunteer_interests_on_volunteer_id", using: :btree

  create_table "volunteers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "occupation"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "email"
    t.string   "home_phone"
    t.string   "work_phone"
    t.string   "mobile_phone"
    t.string   "notes"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "remove_from_mailing_list",  default: false, null: false
    t.date     "waiver_date"
    t.date     "background_check_date"
    t.string   "old_id"
    t.integer  "church_id"
    t.integer  "employer_id"
    t.date     "first_contact_date"
    t.integer  "first_contact_type_id"
    t.integer  "pending_volunteer_id"
    t.datetime "deleted_at"
    t.string   "deleted_reason"
    t.boolean  "needs_review",              default: false
    t.boolean  "adult"
    t.date     "birthdate"
    t.string   "emerg_contact_name"
    t.string   "emerg_contact_phone"
    t.string   "medical_conditions"
    t.string   "limitations"
    t.boolean  "agree_to_background_check"
  end

  add_index "volunteers", ["church_id"], name: "index_volunteers_on_church_id", using: :btree
  add_index "volunteers", ["deleted_at"], name: "index_volunteers_on_deleted_at", using: :btree
  add_index "volunteers", ["employer_id"], name: "index_volunteers_on_employer_id", using: :btree
  add_index "volunteers", ["first_contact_type_id"], name: "index_volunteers_on_first_contact_type_id", using: :btree
  add_index "volunteers", ["old_id"], name: "index_volunteers_on_old_id", using: :btree

  create_table "waiver_texts", force: :cascade do |t|
    t.string   "filename"
    t.binary   "data"
    t.integer  "waiver_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "waivers", force: :cascade do |t|
    t.integer  "volunteer_id"
    t.integer  "guardian_id"
    t.boolean  "adult"
    t.date     "birthdate"
    t.date     "date_signed"
    t.string   "waiver_text"
    t.boolean  "e_sign"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
    t.string   "filename"
    t.binary   "data"
  end

  add_index "waivers", ["deleted_at"], name: "index_waivers_on_deleted_at", using: :btree

  create_table "workday_organizations", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "workday_id"
    t.integer  "num_volunteers"
    t.time     "start_time"
    t.time     "end_time"
    t.float    "hours"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "notes"
  end

  add_index "workday_organizations", ["organization_id"], name: "index_workday_organizations_on_organization_id", using: :btree
  add_index "workday_organizations", ["workday_id"], name: "index_workday_organizations_on_workday_id", using: :btree

  create_table "workday_volunteers", force: :cascade do |t|
    t.integer  "volunteer_id"
    t.integer  "workday_id"
    t.time     "start_time"
    t.time     "end_time"
    t.float    "hours"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "notes"
    t.string   "old_id"
  end

  add_index "workday_volunteers", ["old_id"], name: "index_workday_volunteers_on_old_id", using: :btree
  add_index "workday_volunteers", ["volunteer_id"], name: "index_workday_volunteers_on_volunteer_id", using: :btree
  add_index "workday_volunteers", ["workday_id"], name: "index_workday_volunteers_on_workday_id", using: :btree

  create_table "workdays", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "workdate"
    t.string   "name"
    t.string   "old_id"
    t.string   "notes"
  end

  add_index "workdays", ["old_id"], name: "index_workdays_on_old_id", using: :btree
  add_index "workdays", ["project_id"], name: "index_workdays_on_project_id", using: :btree

end
