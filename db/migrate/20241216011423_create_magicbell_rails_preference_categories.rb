class CreateMagicbellRailsPreferenceCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :magicbell_rails_preference_categories, id: :uuid do |t|
      t.belongs_to :notification_preference, null: false,
                   foreign_key: { to_table: :magicbell_rails_notification_preferences },
                   type: :uuid
      t.string :slug, null: false
      t.timestamps
    end

    add_index :magicbell_rails_preference_categories, [:notification_preference_id, :slug],
              unique: true,
              name: 'index_preference_categories_on_preference_id_and_slug'
  end
end
