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

ActiveRecord::Schema[7.1].define(version: 2024_04_02_075357) do
  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ad_groups", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_name_on_ad_groups"
  end

  create_table "ad_groups_roles", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "ad_group_id", null: false, unsigned: true
    t.integer "role_id", null: false, unsigned: true
    t.text "notes"
    t.index ["ad_group_id"], name: "fk_ad_group_ad_groups_roles"
    t.index ["role_id"], name: "fk_roles_ad_groups_roles"
  end

  create_table "ad_groups_users", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "ad_group_id", null: false, unsigned: true
    t.integer "user_id", null: false, unsigned: true
    t.text "notes"
    t.index ["ad_group_id"], name: "fk_ad_group_ad_groups_users"
    t.index ["user_id"], name: "fk_users_ad_groups_users"
  end

  create_table "node_ips", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "node_id", null: false, unsigned: true
    t.string "ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["ip"], name: "address"
    t.index ["node_id"], name: "fk_node_ips"
  end

  create_table "node_services", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "node_id", null: false, unsigned: true
    t.integer "software_id", null: false, unsigned: true
    t.integer "port"
    t.index ["node_id"], name: "fk_nodes_node_services"
    t.index ["software_id"], name: "fk_softwares_node_services"
  end

  create_table "nodes", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "notes"
    t.integer "role_id", unsigned: true
    t.string "operatingsystem"
    t.string "operatingsystemrelease"
    t.string "kernelversion"
    t.integer "processorcount"
    t.integer "memorysize"
    t.string "datacenter_zone"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["role_id"], name: "fk_roles_id"
  end

  create_table "organizations", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "code", limit: 250
    t.string "name"
    t.string "description"
  end

  create_table "permissions", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id", unsigned: true
    t.integer "organization_id", unsigned: true
    t.string "network", limit: 20
    t.integer "authlevel", unsigned: true
    t.datetime "updated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.index ["organization_id"], name: "fk_organization_permission"
    t.index ["user_id"], name: "fk_user_permission"
  end

  create_table "projects", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
  end

  create_table "projects_roles", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "project_id", null: false, unsigned: true
    t.integer "role_id", null: false, unsigned: true
    t.text "notes"
    t.index ["project_id"], name: "fk_project_projects_roles"
    t.index ["role_id"], name: "fk_roles_projects_roles"
  end

  create_table "roles", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.column "os", "enum('windows','linux')"
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "services", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "url"
    t.text "alive_url"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "softwares", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "notes"
  end

  create_table "ssh_logins", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id", unsigned: true
    t.integer "node_id", unsigned: true
    t.integer "numbers", default: 0, unsigned: true
    t.datetime "last_login", precision: nil
    t.index ["node_id"], name: "fk_nodes_ssh_logins"
    t.index ["user_id"], name: "fk_user_ssh_logins"
  end

  create_table "users", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "upn", null: false
    t.string "name"
    t.string "surname"
    t.string "email"
    t.string "sam"
    t.datetime "updated_at", precision: nil
    t.index ["upn"], name: "index_upn_on_users"
  end

  create_table "web_site_addresses", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "web_site_id", null: false, unsigned: true
    t.string "ip", null: false
    t.integer "port", unsigned: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["ip"], name: "web_sites_addresses_ip"
    t.index ["web_site_id"], name: "fk_web_sites"
  end

  create_table "web_sites", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "name", unique: true, using: :hash
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ad_groups_roles", "ad_groups", name: "fk_ad_group_ad_groups_roles", on_delete: :cascade
  add_foreign_key "ad_groups_roles", "roles", name: "fk_roles_ad_groups_roles", on_delete: :cascade
  add_foreign_key "ad_groups_users", "ad_groups", name: "fk_ad_group_ad_groups_users", on_delete: :cascade
  add_foreign_key "ad_groups_users", "users", name: "fk_users_ad_groups_users", on_delete: :cascade
  add_foreign_key "node_ips", "nodes", name: "fk_node_ips"
  add_foreign_key "node_services", "nodes", name: "fk_.odes_node_services", on_delete: :cascade
  add_foreign_key "node_services", "softwares", name: "fk_softwares_node_services", on_delete: :cascade
  add_foreign_key "nodes", "roles", name: "fk_roles_id", on_delete: :cascade
  add_foreign_key "permissions", "organizations", name: "fk_organization_permission"
  add_foreign_key "permissions", "users", name: "fk_user_permission"
  add_foreign_key "projects_roles", "projects", name: "fk_project_projects_roles", on_delete: :cascade
  add_foreign_key "projects_roles", "roles", name: "fk_roles_projects_roles", on_delete: :cascade
  add_foreign_key "ssh_logins", "nodes", name: "fk_nodes_ssh_logins", on_delete: :cascade
  add_foreign_key "ssh_logins", "users", name: "fk_user_ssh_logins", on_delete: :cascade
  add_foreign_key "web_site_addresses", "web_sites", name: "fk_web_sites"
end
