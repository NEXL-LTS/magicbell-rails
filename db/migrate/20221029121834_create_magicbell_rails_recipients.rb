class CreateMagicbellRailsRecipients < ActiveRecord::Migration[7.0]
  def change
    create_table :magicbell_rails_recipients, id: :uuid do |t|
      t.belongs_to :notification, null: false, foreign_key: { to_table: :magicbell_rails_notifications },
                                  type: :uuid
      t.string :first_name
      t.string :last_name
      t.string :external_id
      t.citext :email
      t.jsonb :custom_attributes

      t.timestamps
    end
  end
end
