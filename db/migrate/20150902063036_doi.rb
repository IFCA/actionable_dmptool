class Doi < ActiveRecord::Migration
  def change
    add_column :plans, :doi, :string
  end
end
