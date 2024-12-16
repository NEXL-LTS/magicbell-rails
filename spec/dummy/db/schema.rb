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

ActiveRecord::Schema[7.2].define(version: 20_241_216_011_427) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'citext'
  enable_extension 'plpgsql'

  create_table 'magicbell_rails_notification_preferences', id: :uuid, default: lambda {
    'gen_random_uuid()'
  }, force: :cascade do |t|
    t.string 'user_external_id', null: false
    t.string 'user_hmac'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_external_id'], name: 'idx_on_user_external_id_41a43c955d', unique: true
  end

  create_table 'magicbell_rails_notifications', id: :uuid, default: lambda {
    'gen_random_uuid()'
  }, force: :cascade do |t|
    t.string 'title', default: '', null: false
    t.string 'topic'
    t.text 'content'
    t.string 'category'
    t.citext 'action_url'
    t.jsonb 'custom_attributes'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.jsonb 'overrides'
  end

  create_table 'magicbell_rails_phones', id: :uuid, default: lambda {
    'gen_random_uuid()'
  }, force: :cascade do |t|
    t.uuid 'recipient_id', null: false
    t.string 'number'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['recipient_id'], name: 'index_magicbell_rails_phones_on_recipient_id'
  end

  create_table 'magicbell_rails_preference_categories', id: :uuid, default: lambda {
    'gen_random_uuid()'
  }, force: :cascade do |t|
    t.uuid 'notification_preference_id', null: false
    t.string 'slug', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[notification_preference_id slug],
            name: 'index_preference_categories_on_preference_id_and_slug', unique: true
    t.index ['notification_preference_id'], name: 'idx_on_notification_preference_id_6fa56179fa'
  end

  create_table 'magicbell_rails_preference_channels', id: :uuid, default: lambda {
    'gen_random_uuid()'
  }, force: :cascade do |t|
    t.uuid 'preference_category_id', null: false
    t.string 'slug', null: false
    t.boolean 'enabled', default: true, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[preference_category_id slug], name: 'index_preference_channels_on_category_id_and_slug',
                                             unique: true
    t.index ['preference_category_id'], name: 'idx_on_preference_category_id_a10924075b'
  end

  create_table 'magicbell_rails_recipients', id: :uuid, default: lambda {
    'gen_random_uuid()'
  }, force: :cascade do |t|
    t.uuid 'notification_id', null: false
    t.string 'first_name'
    t.string 'last_name'
    t.string 'external_id'
    t.citext 'email'
    t.jsonb 'custom_attributes'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['notification_id'], name: 'index_magicbell_rails_recipients_on_notification_id'
  end

  create_table 'magicbell_rails_results', force: :cascade do |t|
    t.uuid 'notification_id', null: false
    t.jsonb 'result'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['notification_id'], name: 'index_magicbell_rails_results_on_notification_id'
  end

  add_foreign_key 'magicbell_rails_phones', 'magicbell_rails_recipients', column: 'recipient_id'
  add_foreign_key 'magicbell_rails_preference_categories', 'magicbell_rails_notification_preferences',
                  column: 'notification_preference_id'
  add_foreign_key 'magicbell_rails_preference_channels', 'magicbell_rails_preference_categories',
                  column: 'preference_category_id'
  add_foreign_key 'magicbell_rails_recipients', 'magicbell_rails_notifications', column: 'notification_id'
  add_foreign_key 'magicbell_rails_results', 'magicbell_rails_notifications', column: 'notification_id'
end
