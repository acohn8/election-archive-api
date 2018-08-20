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

ActiveRecord::Schema.define(version: 2018_08_20_191229) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "candidates", force: :cascade do |t|
    t.string "name"
    t.string "party"
    t.string "normalized_name"
    t.boolean "writein"
    t.string "fec_id"
    t.string "google_id"
    t.string "govtrack_id"
    t.string "opensecrets_id"
    t.string "wikidata_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.integer "office_id"
    t.integer "district_id"
  end

  create_table "counties", force: :cascade do |t|
    t.string "name"
    t.integer "fips"
    t.integer "state_id"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "districts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state_map"
    t.string "county_map"
  end

  create_table "precincts", force: :cascade do |t|
    t.string "name"
    t.integer "state_id"
    t.integer "county_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "results", force: :cascade do |t|
    t.integer "total"
    t.integer "candidate_id"
    t.integer "precinct_id"
    t.integer "county_id"
    t.integer "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "district_id"
    t.integer "office_id"
  end

  create_table "state_offices", force: :cascade do |t|
    t.integer "state_id"
    t.integer "office_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.integer "fips"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
