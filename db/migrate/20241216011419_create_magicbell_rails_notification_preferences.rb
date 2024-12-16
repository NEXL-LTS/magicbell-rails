class CreateMagicbellRailsNotificationPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :magicbell_rails_notification_preferences, id: :uuid do |t|
      t.string :user_external_id, null: false
      t.string :user_hmac
      t.timestamps
    end

    add_index :magicbell_rails_notification_preferences, :user_external_id, unique: true
  end
end
