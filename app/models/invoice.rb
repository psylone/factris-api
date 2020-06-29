class Invoice < ApplicationRecord
  validates :number,
    :issue_date,
    :due_date,
    :purchase_date,
    presence: true

  validates :amount, numericality: { greater_than: 0 }

  belongs_to :contract
end
