class CreateSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :snapshots do |t|
      t.references :investment, null: false, foreign_key: true
      t.date    :snapshot_date, null: false
      t.decimal :current_valuation, precision: 15, scale: 2
      t.decimal :mrr,               precision: 15, scale: 2
      t.decimal :arr,               precision: 15, scale: 2
      t.integer :runway_months
      t.integer :headcount
      t.decimal :last_round_amount, precision: 15, scale: 2
      t.date    :last_round_date
      t.text    :notes

      t.timestamps
    end

    add_index :snapshots, [ :investment_id, :snapshot_date ]
  end
end
