class Contract < ApplicationRecord
  validates :number, :start_date, presence: true

  # By default numericality also doesn't allow `nil`.
  validates :fixed_fee,
    :additional_fee,
    numericality: { greater_than: 0 }

  validates :days_included, numericality: {
    only_integer: true,
    greater_than: 0
  }

  has_many :invoices, dependent: :destroy
end
