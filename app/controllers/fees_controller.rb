class FeesController < ApplicationController
  def create
    fee_params = validate_with!(FeeParamsContract, params.to_unsafe_h)
    result = Fees::CalculateService.call(fee_params[:fee])

    if result.success?
      meta = { fee: result.fee.to_f }

      render json: { meta: meta }, status: :created
    else
      error_response(result.errors, :unprocessable_entity)
    end
  end
end
