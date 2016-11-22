class ChangeRequirementType < ActiveRecord::Migration
  def change
    change_column :requirements, :requirement_type, :enum, limit: [:text, :numeric, :date, :enum, :taxonomy]
  end
end
