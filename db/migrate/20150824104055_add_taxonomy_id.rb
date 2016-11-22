class AddTaxonomyId < ActiveRecord::Migration
  def change
    add_column :requirements, :taxonomy_id, :integer
  end
end
