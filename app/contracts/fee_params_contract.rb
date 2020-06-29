class FeeParamsContract < Dry::Validation::Contract
  config.messages.backend = :i18n

  params do
    required(:fee).hash do
      required(:number).filled(:string)
      required(:issue_date).filled(:date)
      required(:due_date).filled(:date)
      required(:purchase_date).filled(:date)
      required(:amount).filled(:decimal, gt?: 0)
      optional(:paid_date).filled(:date)
    end
  end

  rule('fee.due_date') do
    key.failure(:too_early) if values[:fee][:due_date] <= values[:fee][:issue_date]
  end

  rule('fee.paid_date') do
    key.failure(:too_early) if key? && values[:fee][:paid_date] <= values[:fee][:purchase_date]
  end
end
