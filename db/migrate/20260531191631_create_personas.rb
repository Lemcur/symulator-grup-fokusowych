class CreatePersonas < ActiveRecord::Migration[8.1]
  def change
    create_table :personas do |t|
      t.string :name
      t.text :description
      t.jsonb :demographics
      t.jsonb :traits
      t.references :focus_group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
