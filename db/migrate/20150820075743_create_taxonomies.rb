class CreateTaxonomies < ActiveRecord::Migration
  def change
    create_table :taxonomies do |t|
      t.string :name
      t.text :description
      t.string :url

      t.timestamps
    end
  end
end
