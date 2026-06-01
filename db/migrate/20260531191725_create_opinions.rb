class CreateOpinions < ActiveRecord::Migration[8.1]
  def change
    create_table :opinions do |t|
      t.integer :round, null: false, default: 0
      t.boolean :revised, null: false, default: false
      t.text :revision_rationale
      t.integer :rating
      t.text :pros
      t.text :cons
      t.text :quote
      t.jsonb :raw_response
      t.integer :status, null: false, default: 0
      t.text :error_message
      t.references :persona, null: false, foreign_key: true
      t.references :focus_group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :opinions, [:persona_id, :round], unique: true
    add_index :opinions, [:focus_group_id, :round]
  end
end
