class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|
      t.string :number, null: false
      t.boolean :active, null: false, default: true, index: true
      t.date :start_date, null: false
      t.date :end_date
      t.decimal :fixed_fee, null: false
      t.integer :days_included, null: false
      t.decimal :additional_fee, null: false
      t.timestamps
    end

    add_index :contracts, %i[number start_date end_date], unique: true
  end
end
