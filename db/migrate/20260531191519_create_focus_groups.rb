class CreateFocusGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :focus_groups do |t|
      t.string :name, null: false
      t.integer :sample_size, null: false
      t.integer :generation_mode, null: false, default: 0
      t.jsonb :target_demographics, null: false, default: {}
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :deliberation_started_at
      t.datetime :synthesis_started_at
      t.datetime :completed_at
      t.text :error_message
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :focus_groups, :status
  end
end
