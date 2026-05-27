class AddVehicleToInvestments < ActiveRecord::Migration[8.1]
  def change
    add_column :investments, :vehicle, :string, default: "direct", null: false
  end
end
