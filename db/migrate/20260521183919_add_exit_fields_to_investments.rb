class AddExitFieldsToInvestments < ActiveRecord::Migration[8.1]
  def change
    add_column :investments, :exit_date, :date
    add_column :investments, :exit_amount, :decimal, precision: 15, scale: 2
  end
end
