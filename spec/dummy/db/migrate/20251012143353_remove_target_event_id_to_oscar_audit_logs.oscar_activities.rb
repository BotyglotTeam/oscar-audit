# This migration comes from oscar_audit (originally 20251011084602)
class RemoveTargetEventIdToOscarAuditLogs < ActiveRecord::Migration[8.0]
  def change
    remove_column :oscar_audit_logs, :target_event_id, :string, null: true
  end


end
