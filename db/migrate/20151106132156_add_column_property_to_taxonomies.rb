class AddColumnPropertyToTaxonomies < ActiveRecord::Migration
  def change
    add_column :taxonomies, :property, :string
  end
end
