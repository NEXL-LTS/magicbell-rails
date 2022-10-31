class CreateMagicbellRailsResults < ActiveRecord::Migration[7.0]
  def change
    create_table :magicbell_rails_results do |t|
      t.belongs_to :notification, null: false, foreign_key: { to_table: :magicbell_rails_notifications },
                                  type: :uuid
      t.jsonb :result

      t.timestamps
    end
  end
end
