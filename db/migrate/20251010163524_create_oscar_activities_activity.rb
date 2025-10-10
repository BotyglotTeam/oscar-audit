class CreateOscarActivitiesActivity < ActiveRecord::Migration[8.0]
  def change
    create_table :oscar_activities_activities, **table_id_opt do |t|
      # FK to definitions table (Oscar::Activities::ActivityDefinition)
      t.references :activity_definition,
                   **reference_opt,
                   null: false,
                   foreign_key: { to_table: :oscar_activities_activity_definitions },
                   index: { name: "idx_oa_acts_on_definition_id" }

      # Who performed the action
      t.references :actor,
                   **reference_opt,
                   polymorphic: true,
                   null: false,
                   index: { name: "idx_oa_acts_on_actor" }

      # Optional impersonator
      t.references :impersonated_by,
                   **reference_opt,
                   polymorphic: true,
                   index: { name: "idx_oa_acts_on_impersonated_by" }

      # The affected record
      t.references :target,
                   **reference_opt,
                   polymorphic: true,
                   null: false,
                   index: { name: "idx_oa_acts_on_target" }

      # Project-specific log entry (instance of the definition's log_type)
      t.references :log,
                   **reference_opt,
                   polymorphic: true,
                   index: { name: "idx_oa_acts_on_log" }

      t.timestamps
    end

    add_index :oscar_activities_activities, :created_at, name: "idx_oa_acts_on_created_at"
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
