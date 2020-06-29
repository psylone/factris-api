class ContractsController < ApplicationController
  def create
    # We can do it inside `before_action`, but since we have
    # it in only one place, let's call `validate_with!` here
    #
    # Also `ContractParamsContract` sounds a little bit tricky,
    # nonetheless, it reflects the essence of this validation contract
    contract_params = validate_with!(ContractParamsContract, params.to_unsafe_h)

    # Technically with dry-initializer we already will have only defined params
    # inside the service object. But it's convenient to check params
    # as early as possible and not call service at all if params are invalid
    result = Contracts::CreateOrUpdateService.call(contract_params[:contract])

    if result.success?
      serializer = ContractSerializer.new(result.contract)
      render json: serializer.serializable_hash, status: :created
    else
      error_response(result.contract, :unprocessable_entity)
    end
  end
end
