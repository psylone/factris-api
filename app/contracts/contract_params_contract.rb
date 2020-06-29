class ContractParamsContract < Dry::Validation::Contract
  config.messages.backend = :i18n

  params do
    required(:contract).hash do
      required(:number).filled(:string)
      required(:start_date).filled(:date)
      required(:fixed_fee).filled(:decimal, gt?: 0)
      required(:days_included).filled(:integer, gt?: 0)
      required(:additional_fee).filled(:decimal, gt?: 0)
      optional(:active).filled(:bool)
      optional(:end_date).filled(:date)
    end
  end

  rule('contract.end_date') do
    key.failure(:too_early) if key? && values[:contract][:end_date] <= values[:contract][:start_date]
  end
end
