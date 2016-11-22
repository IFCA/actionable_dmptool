class AddColumnPreflabelToTaxonomies < ActiveRecord::Migration
  def change
    add_column :taxonomies, :prefLabel, :string
  end
end
