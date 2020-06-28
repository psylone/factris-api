FactoryBot.define do
  sequence(:contract_number) do |n|
    "A#{n}"
  end
end
