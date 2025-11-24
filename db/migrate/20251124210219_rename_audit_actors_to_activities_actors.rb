class RenameAuditActorsToActivitiesActors < ActiveRecord::Migration[8.0]
  def change
    remove_index :oscar_audit_actors, :type, name: "idx_oaudit_actors_on_type"
    rename_table :oscar_audit_actors, :oscar_activities_actors
    add_index :oscar_activities_actors, :type, name: "idx_oscar_activities_actors_on_type"

  end
end
