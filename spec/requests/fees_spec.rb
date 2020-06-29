RSpec.describe 'Fees API', type: :request do
  describe 'POST /api/v1/fees' do
    context 'missing parameters' do
      it 'returns an error' do
        post '/api/v1/fees'

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body['errors']).to eq(
          [{ 'detail' => 'The request is missing the required parameters' }]
        )
      end
    end

    context 'invalid parameters' do
      let(:params) do
        {
          number: '',
          issue_date: '2019-01-01'.to_date,
          due_date: '2019-01-15'.to_date,
          paid_date: '2019-01-20'.to_date,
          purchase_date: '2019-01-05'.to_date,
          amount: 1000.00
        }
      end

      it 'returns an error' do
        post '/api/v1/fees', params: { fee: params }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'missing contract' do
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

      it 'returns an error' do
        post '/api/v1/fees', params: { fee: params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body['errors']).to eq(
          [{ 'detail' => 'There is no contract for such invoice' }]
        )
      end
    end

    context 'valid parameters' do
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

      before do
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

      it 'returns a fee' do
        post '/api/v1/fees', params: { fee: params }

        expect(response).to have_http_status(:created)
        expect(response_body['meta']).to eq('fee' => 22.0)
      end
    end
  end
end
