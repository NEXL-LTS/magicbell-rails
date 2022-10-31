class CreateMagicbellRailsNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :magicbell_rails_notifications, id: :uuid do |t|
      t.string :title, default: '', null: false
      t.string :topic
      t.text :content
      t.string :category
      t.citext :action_url
      t.jsonb :custom_attributes

      t.timestamps
    end
  end
end
