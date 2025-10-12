class CreateOscarAuditActors < ActiveRecord::Migration[8.0]
  def change
    create_table :oscar_audit_actors, **table_id_opt do |t|
      t.integer :type, null: false, default: 0
      t.string :name, null: false
      t.timestamps
    end

    add_index :oscar_audit_actors, :type, name: "idx_oaudit_actors_on_type"
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
end
