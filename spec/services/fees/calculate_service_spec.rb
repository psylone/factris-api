RSpec.describe Fees::CalculateService do
  subject { described_class }

  let(:params) do
    {
      number: 'A10',
      issue_date: '2019-01-01'.to_date,
      due_date: '2019-01-15'.to_date,
      paid_date: '2019-01-20'.to_date,
      purchase_date: '2019-01-05'.to_date,
      amount: 1000.00
    }
  end

  context 'missing contract' do
    it 'returns errors' do
      result = subject.call(params)

      expect(result).to be_failure
      expect(result.errors).to eq(['There is no contract for such invoice'])
    end
  end

  context 'without paid_date' do
    let(:date) { '2019-01-25'.to_date }

    let!(:contract) do
      create(
        :contract,
        number: params[:number],
        start_date: '2019-01-01',
        end_date: '2019-09-30',
        fixed_fee: 0.02,
        days_included: 14,
        additional_fee: 0.001
      )
    end

    before do
      params.delete(:paid_date)
    end

    it 'calculates fees till the present date (including)' do
      travel_to(date) do
        result = subject.call(params)

        expect(result).to be_success
        expect(result.fee).to eq(27.0)
      end
    end

    it 'creates invoice' do
      expect { subject.call(params) }
        .to change { contract.invoices.count }.from(0).to(1)
    end
  end

  context 'with paid date' do
    let!(:contract) do
      create(
        :contract,
        number: params[:number],
        start_date: '2019-01-01',
        end_date: '2019-09-30',
        fixed_fee: 0.02,
        days_included: 14,
        additional_fee: 0.001
      )
    end

    it 'calculates fees till the present date (including)' do
      result = subject.call(params)

      expect(result).to be_success
      expect(result.fee).to eq(22.0)
    end

    it 'creates invoice' do
      expect { subject.call(params) }
        .to change { contract.invoices.count }.from(0).to(1)
    end
  end
end
