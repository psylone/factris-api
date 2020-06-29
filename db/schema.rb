# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_29_213430) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contracts", force: :cascade do |t|
    t.string "number", null: false
    t.boolean "active", default: true, null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.decimal "fixed_fee", null: false
    t.integer "days_included", null: false
    t.decimal "additional_fee", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["active"], name: "index_contracts_on_active"
    t.index ["number", "start_date", "end_date"], name: "index_contracts_on_number_and_start_date_and_end_date", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.string "number", null: false
    t.date "issue_date", null: false
    t.date "due_date", null: false
    t.date "purchase_date", null: false
    t.decimal "amount", null: false
    t.date "paid_date"
    t.bigint "contract_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contract_id"], name: "index_invoices_on_contract_id"
  end

  add_foreign_key "invoices", "contracts"
end
