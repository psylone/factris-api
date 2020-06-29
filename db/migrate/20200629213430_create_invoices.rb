class CreateInvoices < ActiveRecord::Migration[6.0]
  def change
    create_table :invoices do |t|
      t.string :number, null: false
      t.date :issue_date, null: false
      t.date :due_date, null: false
      t.date :purchase_date, null: false
      t.decimal :amount, null: false
      t.date :paid_date
      t.references :contract, null: false, foreign_key: true
      t.timestamps
    end
  end
end
