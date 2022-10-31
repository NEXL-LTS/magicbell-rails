class CreateMagicbellRailsPhones < ActiveRecord::Migration[7.0]
  def change
    create_table :magicbell_rails_phones, id: :uuid do |t|
      t.belongs_to :recipient, null: false, foreign_key: { to_table: :magicbell_rails_recipients },
                               type: :uuid
      t.string :number

      t.timestamps
    end
  end
end
