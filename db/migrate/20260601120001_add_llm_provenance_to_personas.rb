class AddLlmProvenanceToPersonas < ActiveRecord::Migration[8.1]
  def change
    change_table :personas do |t|
      t.string :llm_model
      t.string :llm_provider
    end

    add_index :personas, :llm_model
  end
end
