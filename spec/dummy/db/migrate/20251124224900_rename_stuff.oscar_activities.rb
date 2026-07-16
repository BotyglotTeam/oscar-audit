# This migration comes from oscar_activities (originally 20251124210220)
class RenameStuff < ActiveRecord::Migration[8.0]
  def change
    rename_table :oscar_activities_logs, :oscar_activities_activities
    rename_column :oscar_activities_activities, :application_log_id, :application_activity_id
    rename_column :oscar_activities_activities, :application_log_type, :application_activity_type
  end
end

