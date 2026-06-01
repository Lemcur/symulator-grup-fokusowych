class ExtendFocusGroupsForRecruitmentBrief < ActiveRecord::Migration[8.1]
  def change
    change_table :focus_groups do |t|
      t.jsonb :inclusion_criteria, default: []
      t.jsonb :exclusion_criteria, default: []
      t.text :brief_summary
      t.integer :persona_generator, default: 0, null: false
    end
  end
end
