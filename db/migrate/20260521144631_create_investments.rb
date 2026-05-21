class CreateInvestments < ActiveRecord::Migration[8.1]
  def change
    create_table :investments do |t|
      t.string  :company_name, null: false
      t.string  :sector
      t.string  :stage
      t.decimal :invested_amount,   precision: 15, scale: 2, null: false
      t.decimal :entry_valuation,   precision: 15, scale: 2
      t.decimal :equity_percentage, precision: 8,  scale: 4
      t.date    :investment_date, null: false
      t.string  :status, null: false, default: "active"
      t.string  :website
      t.text    :description

      t.timestamps
    end

    add_index :investments, :status
    add_index :investments, :sector
  end
end
