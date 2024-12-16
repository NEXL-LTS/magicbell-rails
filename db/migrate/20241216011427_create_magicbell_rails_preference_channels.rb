class CreateMagicbellRailsPreferenceChannels < ActiveRecord::Migration[7.2]
  def change
    create_table :magicbell_rails_preference_channels, id: :uuid do |t|
      t.belongs_to :preference_category, null: false,
                   foreign_key: { to_table: :magicbell_rails_preference_categories },
                   type: :uuid
      t.string :slug, null: false
      t.boolean :enabled, null: false, default: true
      t.timestamps
    end

    add_index :magicbell_rails_preference_channels, [:preference_category_id, :slug],
              unique: true,
              name: 'index_preference_channels_on_category_id_and_slug'
  end
end
