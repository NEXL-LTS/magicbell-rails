class AddOverridesColumnToMagicbellRailsNotificationsTable < ActiveRecord::Migration[7.0]
  def change
    add_column :magicbell_rails_notifications, :overrides, :jsonb
  end
end
