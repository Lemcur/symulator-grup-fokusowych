class AddAdditionalRequirementsToFocusGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :focus_groups, :additional_requirements, :text
  end
end
