FactoryBot.define do
  factory :contract do
    number { generate(:contract_number) }
    start_date { Date.current }
    fixed_fee { 0.02 }
    days_included { 14 }
    additional_fee { 0.001 }
  end
end
