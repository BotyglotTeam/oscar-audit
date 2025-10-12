class RemoveTargetEventIdToOscarAuditLogs < ActiveRecord::Migration[8.0]
  def change
    remove_column :oscar_audit_logs, :target_event_id, :string, null: true
  end


end
