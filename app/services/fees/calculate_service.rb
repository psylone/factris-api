module Fees
  class CalculateService
    prepend BasicService

    option :number
    option :issue_date
    option :due_date
    option :purchase_date
    option :amount
    option :paid_date, default: proc { Date.current }
    option :contract, default: proc { fetch_contract }

    attr_reader :fee

    def call
      return fail!(I18n.t(:missing_contract, scope: 'services.fees.calculate_service')) if @contract.blank?

      @fee = fixed_fee + additional_fee
    end

    private

    def fetch_contract
      Contract.where(number: @number)
        .where(%[start_date <= ?], @issue_date)
        .where(%[(end_date IS NULL OR end_date >= ?)], @due_date)
        .order('end_date DESC NULLS FIRST')
        .first
    end

    def fixed_fee
      @contract.fixed_fee * @amount
    end

    def additional_fee
      paid_days * @contract.additional_fee * @amount
    end

    def paid_days
      days_included_end_date = @purchase_date + @contract.days_included
      (@paid_date - days_included_end_date + 1).to_i
    end
  end
end
