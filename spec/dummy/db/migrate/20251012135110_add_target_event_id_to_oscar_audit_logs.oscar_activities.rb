# This migration comes from oscar_audit (originally 20251011084601)
class AddTargetEventIdToOscarAuditLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :oscar_audit_logs, :target_event_id, :string, null: true
    add_index :oscar_audit_logs, :target_event_id, unique: true
  end


end

