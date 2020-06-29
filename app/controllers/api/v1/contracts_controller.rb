class Api::V1::ContractsController < ApplicationController
  def create
    contract_params = validate_with!(ContractParamsContract, params.to_unsafe_h)
    result = Contracts::CreateOrUpdateService.call(contract_params[:contract])

    if result.success?
      serializer = ContractSerializer.new(result.contract)
      render json: serializer.serializable_hash, status: :created
    else
      error_response(result.contract, :unprocessable_entity)
    end
  end
end
