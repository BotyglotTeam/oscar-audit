# This migration comes from oscar_activities (originally 20251124210218)
class RenameAuditLogToActivitiesLog < ActiveRecord::Migration[8.0]
  def change
    remove_index :oscar_audit_logs, :created_at, name: "idx_oscars_audit_logs_on_created_at"
    rename_table :oscar_audit_logs, :oscar_activities_logs
    add_index :oscar_activities_logs, :created_at, name: "idx_oscars_activities_logs_on_created_at"

  end
end
