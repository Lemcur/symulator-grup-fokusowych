class CreateChairmen < ActiveRecord::Migration[8.1]
  def change
    create_table :chairmen do |t|
      t.string :llm_model, null: false
      t.string :role
      t.references :focus_group, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
