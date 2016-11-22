class AddColumnNamespaceToTaxonomies < ActiveRecord::Migration
  def change
    add_column :taxonomies, :namespace, :string
  end
end
