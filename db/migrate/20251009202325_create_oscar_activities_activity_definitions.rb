class CreateOscarActivitiesActivityDefinitions < ActiveRecord::Migration[7.1]
  def change
    create_table :oscar_activities_activity_definitions, **table_id_opt do |t|
      t.string :model_type, null: false
      t.string :model_event_name, null: false
      t.string :log_type, null: false
      t.timestamps
    end

    add_index :oscar_activities_activity_definitions,
              %i[model_type model_event_name],
              unique: true,
              name: "idx_oa_acts_def_on_model_event"
  end

  private
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