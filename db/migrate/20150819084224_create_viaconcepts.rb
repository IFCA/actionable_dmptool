class CreateViaconcepts < ActiveRecord::Migration
  def change
    create_table :viaconcepts do |t|
      t.string :identifier
      t.string :label
      t.text :description
      t.string :parent
      t.string :taxonomy

      t.timestamps
    end

  end
end
