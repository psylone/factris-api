module Validations
  class InvalidParams < StandardError; end

  def validate_with!(validation, params)
    result = validate_with(validation, params)
    raise InvalidParams if result.failure?
    result
  end

  def validate_with(validation, params)
    contract = validation.new
    contract.call(params)
  end
end
