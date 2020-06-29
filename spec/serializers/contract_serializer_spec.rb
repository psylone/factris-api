RSpec.describe ContractSerializer do
  subject { described_class.new(contract) }

  let(:contract) { create(:contract) }

  let(:attributes) do
    contract.slice(
      :number,
      :active,
      :start_date,
      :end_date,
      :fixed_fee,
      :days_included,
      :additional_fee
    ).symbolize_keys
  end

  it 'returns contract representation' do
    expect(subject.serializable_hash).to a_hash_including(
      data: {
        id: contract.id.to_s,
        type: :contract,
        attributes: attributes
      }
    )
  end
end
