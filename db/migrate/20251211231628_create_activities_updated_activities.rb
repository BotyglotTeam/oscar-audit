class CreateActivitiesUpdatedActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities_updated_activities,  **table_id_opt  do |t|
      t.string :type
      t.references :version_record,
                   **reference_opt,
                   polymorphic: true
      t.timestamps
    end
  end


  # Use in any migration
  def host_pk_type
    Rails.application.config.generators
         .options.dig(:active_record, :primary_key_type)
  end

  def table_id_opt
    (t = host_pk_type) ? { id: t } : {}
  end

  def reference_opt
    (t = host_pk_type) ? { type: t } : {}
  end
end
