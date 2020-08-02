RSpec.describe Contracts::CreateOrUpdateService do
  subject { described_class }

  let(:params) { attributes_for(:contract) }

  context 'invalid params' do
    before do
      params[:number] = ''
    end

    it 'does not create a contract' do
      expect { subject.call(params) }.not_to change { Contract.count }
    end

    it 'assigns contract' do
      result = subject.call(params)

      expect(result).to be_failure
      expect(result.contract).to be_kind_of(Contract)
    end
  end

  context 'valid params' do
    it 'creates a contract' do
      expect { subject.call(params) }.to change { Contract.count }.from(0).to(1)
    end

    it 'assigns contract' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract).to be_kind_of(Contract)
    end
  end

  context 'existing contract' do
    let(:contract) { create(:contract, fixed_fee: 0.02) }

    before do
      params[:number] = contract.number
      params[:start_date] = contract.start_date
      params[:end_date] = contract.end_date
      params[:fixed_fee] = 0.03
    end

    it 'does not create a new contract' do
      expect { subject.call(params) }.not_to change { Contract.count }
    end

    it 'updates contract' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract.fixed_fee).to eq(0.03)
    end
  end

  context 'existing surrounding contract without end_date' do
    let(:surrounding_contract) { create(:contract, start_date: '2020-01-21') }

    before do
      params[:number] = surrounding_contract.number
      params[:start_date] = '2020-01-25'
    end

    it 'creates a new contract and makes it inactive' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract).to be_persisted
      expect(result.contract).not_to be_active
    end

    it 'keeps surrounding contract active' do
      subject.call(params)

      expect(surrounding_contract.reload).to be_active
    end
  end

  context 'existing surrounding contract with end_date' do
    let(:surrounding_contract) { create(:contract, start_date: '2020-01-21', end_date: '2020-07-15') }

    before do
      params[:number] = surrounding_contract.number
      params[:start_date] = '2020-01-25'
      params[:end_date] = '2020-06-15'
    end

    it 'creates a new contract and makes it inactive' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract).to be_persisted
      expect(result.contract).not_to be_active
    end

    it 'keeps surrounding contract active' do
      subject.call(params)

      expect(surrounding_contract.reload).to be_active
    end
  end

  context 'existing surrounding contract with end_date and new contract without end_date' do
    let(:surrounding_contract) { create(:contract, start_date: '2020-01-21', end_date: '2020-07-15') }

    before do
      params[:number] = surrounding_contract.number
      params[:start_date] = '2020-01-25'
    end

    it 'creates a new active contract' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract).to be_persisted
      expect(result.contract).to be_active
    end

    it 'keeps surrounding contract active' do
      subject.call(params)

      expect(surrounding_contract.reload).to be_active
    end
  end

  context 'with overlapping contracts and new contract without end_date' do
    let(:overlapping_contract) { create(:contract, start_date: '2020-01-21') }

    before do
      params[:number] = overlapping_contract.number
      params[:start_date] = '2020-01-15'
    end

    it 'creates a new active contract' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract).to be_persisted
      expect(result.contract).to be_active
    end

    it 'makes overlapping contract inactive' do
      subject.call(params)

      expect(overlapping_contract.reload).not_to be_active
    end
  end

  context 'with overlapping contracts and new contract with end_date' do
    let(:overlapping_contract) { create(:contract, start_date: '2020-01-21', end_date: '2020-07-15') }

    before do
      params[:number] = overlapping_contract.number
      params[:start_date] = '2020-01-15'
      params[:end_date] = '2020-07-21'
    end

    it 'creates a new active contract' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract).to be_persisted
      expect(result.contract).to be_active
    end

    it 'makes overlapping contract inactive' do
      subject.call(params)

      expect(overlapping_contract.reload).not_to be_active
    end
  end

  context 'without overlapping contracts' do
    let(:existing_contract) { create(:contract, start_date: '2020-01-21', end_date: '2020-07-15') }

    before do
      params[:number] = existing_contract.number
      params[:start_date] = '2020-07-10'
      params[:end_date] = '2020-07-21'
    end

    it 'creates a new active contract' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract).to be_persisted
      expect(result.contract).to be_active
    end

    it 'keeps existing contract active' do
      subject.call(params)

      expect(existing_contract.reload).to be_active
    end
  end

  context 'with partially overlapping contracts' do
    let!(:first_contract) do
      create(
        :contract,
        number: 'A10',
        start_date: '2019-01-01',
        end_date: '2019-09-30',
        fixed_fee: 0.02,
        days_included: 14,
        additional_fee: 0.001
      )
    end

    let!(:last_contract) do
      create(
        :contract,
        number: 'A10',
        start_date: '2020-01-01',
        fixed_fee: 0.0175,
        days_included: 14,
        additional_fee: 0.001
      )
    end

    before do
      params[:number] = 'A10'
      params[:start_date] = '2019-09-01'
      params[:end_date] = '2020-01-31'
      params[:fixed_fee] = 0.019
      params[:days_included] = 14
      params[:additional_fee] = 0.001
    end

    it 'creates a new active contract' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.contract).to be_persisted
      expect(result.contract).to be_active
    end

    it 'changes end_date for existing contracts' do
      result = subject.call(params)
      first_contract.reload

      expect(first_contract).to be_active
      expect(first_contract.start_date).to eq('2019-01-01'.to_date)
      expect(first_contract.end_date).to eq('2019-08-31'.to_date)
    end

    it 'changes start_date for existing contracts' do
      result = subject.call(params)
      last_contract.reload

      expect(last_contract).to be_active
      expect(last_contract.start_date).to eq('2020-02-01'.to_date)
      expect(last_contract.end_date).to be_nil
    end
  end
end
