class ContractSerializer
  include JSONAPI::Serializer

  attributes :number,
    :active,
    :start_date,
    :end_date,
    :fixed_fee,
    :days_included,
    :additional_fee
end
