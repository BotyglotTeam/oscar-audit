class CreateFieldChange < ActiveRecord::Migration[8.0]
  def change
    create_table :activities_field_changes,  **table_id_opt  do |t|
      t.string :type
      t.string :field_name
      t.boolean :previous_boolean_value
      t.boolean :boolean_value
      t.integer :previous_integer_value
      t.integer :integer_value
      t.decimal :previous_decimal_value
      t.decimal :decimal_value
      t.string :previous_string_value
      t.string :string_value
      t.text :previous_text_value
      t.text :text_value
      t.references :previous_record_value, **reference_opt
      t.references :record_value, **reference_opt
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
