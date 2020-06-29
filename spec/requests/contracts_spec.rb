RSpec.describe 'Contracts API', type: :request do
  describe 'POST /contracts' do
    context 'missing parameters' do
      it 'returns an error' do
        post '/contracts'

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
          start_date: '2019-01-01',
          fixed_fee: 0.02,
          days_included: 14,
          additional_fee: 0.001
        }
      end

      it 'returns an error' do
        post '/contracts', params: { contract: params }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'valid parameters' do
      let(:params) do
        {
          number: 'A10',
          active: true,
          start_date: '2019-01-01',
          end_date: '2019-09-30',
          fixed_fee: 0.02,
          days_included: 14,
          additional_fee: 0.001
        }
      end

      let(:last_contract) { Contract.last }

      it 'creates a new contract' do
        expect { post '/contracts', params: { contract: params } }
          .to change { Contract.count }.from(0).to(1)

        expect(response).to have_http_status(:created)
      end

      it 'returns a contract' do
        post '/contracts', params: { contract: params }

        expect(response_body['data']).to a_hash_including(
          'id' => last_contract.id.to_s,
          'type' => 'contract'
        )
      end
    end
  end
end
