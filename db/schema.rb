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

ActiveRecord::Schema.define(version: 2020_03_30_192156) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "plpgsql"

  create_table "contact_methods", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "inactive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "inactive", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.datetime "date_time"
    t.integer "contact_method_id"
    t.integer "volunteer_id"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "user_id"
    t.integer "last_edit_user_id"
    t.index ["deleted_at"], name: "index_contacts_on_deleted_at"
    t.index ["volunteer_id"], name: "index_contacts_on_volunteer_id"
  end

  create_table "donation_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "non_monetary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "inactive", default: false, null: false
  end

  create_table "donations", id: :serial, force: :cascade do |t|
    t.date "date_received"
    t.decimal "value"
    t.string "ref_no"
    t.string "item"
    t.boolean "anonymous", default: false, null: false
    t.string "in_honor_of"
    t.string "designation"
    t.string "notes"
    t.boolean "receipt_sent", default: false, null: false
    t.integer "volunteer_id"
    t.integer "organization_id"
    t.integer "donation_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "old_id"
    t.index ["donation_type_id"], name: "index_donations_on_donation_type_id"
    t.index ["organization_id"], name: "index_donations_on_organization_id"
    t.index ["volunteer_id"], name: "index_donations_on_volunteer_id"
  end

  create_table "homeowner_projects", force: :cascade do |t|
    t.integer "project_id"
    t.integer "volunteer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_homeowner_projects_on_project_id"
    t.index ["volunteer_id"], name: "index_homeowner_projects_on_volunteer_id"
  end

  create_table "interest_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interests", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "interest_category_id"
    t.boolean "highlight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "inactive", default: false, null: false
    t.boolean "include_on_application", default: false
    t.index ["interest_category_id"], name: "index_interests_on_interest_category_id"
  end

  create_table "organization_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "inactive", default: false, null: false
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "organization_type_id"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "email"
    t.string "phone"
    t.string "notes"
    t.string "contact_name"
    t.string "old_id"
    t.boolean "remove_from_mailing_list", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_type_id"], name: "index_organizations_on_organization_type_id"
  end

  create_table "pending_volunteer_interests", id: :serial, force: :cascade do |t|
    t.integer "interest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pending_volunteer_id"
    t.index ["interest_id"], name: "index_pending_volunteer_interests_on_interest_id"
  end

  create_table "pending_volunteers", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "email"
    t.string "city"
    t.boolean "resolved", default: false, null: false
    t.string "xml"
    t.string "raw"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "notes"
    t.integer "volunteer_id"
    t.string "home_phone"
    t.string "work_phone"
    t.string "mobile_phone"
    t.index ["volunteer_id"], name: "index_pending_volunteers_on_volunteer_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "inactive", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "old_id"
    t.string "description"
    t.integer "old_project_id"
    t.index ["old_id"], name: "index_projects_on_old_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "site_title"
    t.string "org_title"
    t.string "org_short_title"
    t.string "org_site"
    t.string "old_system_site"
    t.string "old_system_name"
    t.boolean "no_pagination"
    t.integer "records_per_page"
    t.integer "min_password_length"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "adult_waiver_text"
    t.string "minor_waiver_text"
    t.integer "waiver_valid_days"
    t.boolean "allow_waiver_skip"
    t.integer "adult_age"
    t.boolean "waivers_at_checkin"
    t.string "pending_volunteer_notify_email"
    t.string "email_account"
    t.string "email_password"
    t.string "smtp_server"
    t.string "smtp_port"
    t.boolean "smtp_starttls", default: true
    t.boolean "smtp_ssl", default: true
    t.boolean "smtp_tls", default: true
    t.string "site_url"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.boolean "all_donations", default: false, null: false
    t.boolean "non_monetary_donations", default: false, null: false
    t.boolean "can_edit_unowned_contacts", default: false
    t.boolean "notify_if_pending", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "volunteer_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "inactive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "volunteer_category_volunteers", id: :serial, force: :cascade do |t|
    t.integer "volunteer_id"
    t.integer "volunteer_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volunteer_category_id"], name: "index_volunteer_category_volunteers_on_volunteer_category_id"
    t.index ["volunteer_id"], name: "index_volunteer_category_volunteers_on_volunteer_id"
  end

  create_table "volunteer_interests", id: :serial, force: :cascade do |t|
    t.integer "volunteer_id"
    t.integer "interest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interest_id"], name: "index_volunteer_interests_on_interest_id"
    t.index ["volunteer_id"], name: "index_volunteer_interests_on_volunteer_id"
  end

  create_table "volunteers", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "occupation"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "email"
    t.string "home_phone"
    t.string "work_phone"
    t.string "mobile_phone"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "remove_from_mailing_list", default: false, null: false
    t.date "waiver_date"
    t.date "background_check_date"
    t.string "old_id"
    t.integer "church_id"
    t.integer "employer_id"
    t.date "first_contact_date"
    t.integer "first_contact_type_id"
    t.integer "pending_volunteer_id"
    t.datetime "deleted_at"
    t.string "deleted_reason"
    t.boolean "needs_review", default: false
    t.boolean "adult"
    t.date "birthdate"
    t.string "emerg_contact_name"
    t.string "emerg_contact_phone"
    t.string "medical_conditions"
    t.string "limitations"
    t.boolean "agree_to_background_check"
    t.boolean "primary_employer_contact"
    t.boolean "primary_church_contact"
    t.index ["church_id"], name: "index_volunteers_on_church_id"
    t.index ["deleted_at"], name: "index_volunteers_on_deleted_at"
    t.index ["employer_id"], name: "index_volunteers_on_employer_id"
    t.index ["first_contact_type_id"], name: "index_volunteers_on_first_contact_type_id"
    t.index ["old_id"], name: "index_volunteers_on_old_id"
  end

  create_table "waiver_texts", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.binary "data"
    t.integer "waiver_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "waivers", id: :serial, force: :cascade do |t|
    t.integer "volunteer_id"
    t.integer "guardian_id"
    t.boolean "adult"
    t.date "birthdate"
    t.date "date_signed"
    t.string "waiver_text"
    t.boolean "e_sign"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "filename"
    t.binary "data"
    t.index ["deleted_at"], name: "index_waivers_on_deleted_at"
  end

  create_table "workday_organizations", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "workday_id"
    t.integer "num_volunteers"
    t.time "start_time"
    t.time "end_time"
    t.float "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notes"
    t.index ["organization_id"], name: "index_workday_organizations_on_organization_id"
    t.index ["workday_id"], name: "index_workday_organizations_on_workday_id"
  end

  create_table "workday_volunteers", id: :serial, force: :cascade do |t|
    t.integer "volunteer_id"
    t.integer "workday_id"
    t.time "start_time"
    t.time "end_time"
    t.float "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notes"
    t.string "old_id"
    t.integer "donated_to_id"
    t.index ["old_id"], name: "index_workday_volunteers_on_old_id"
    t.index ["volunteer_id"], name: "index_workday_volunteers_on_volunteer_id"
    t.index ["workday_id"], name: "index_workday_volunteers_on_workday_id"
  end

  create_table "workdays", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "workdate"
    t.string "name"
    t.string "old_id"
    t.string "notes"
    t.integer "old_project_id"
    t.index ["old_id"], name: "index_workdays_on_old_id"
    t.index ["project_id"], name: "index_workdays_on_project_id"
  end

end
