module Contracts
  class CreateOrUpdateService
    prepend BasicService

    option :number
    option :start_date
    option :fixed_fee
    option :days_included
    option :additional_fee
    option :active, default: proc { true }
    option :end_date, optional: true

    attr_reader :contract

    def call
      @contract = Contract.find_or_initialize_by(
        number: @number,
        start_date: @start_date,
        end_date: @end_date
      )

      Contract.transaction do
        store_contract!
        process_self_overlapping!
        process_overlapping if @contract.active?
      end
    rescue ActiveRecord::RecordInvalid
      fail!(@contract.errors)
    end

    private

    def store_contract!
      @contract.update!(
        fixed_fee: @fixed_fee,
        days_included: @days_included,
        additional_fee: @additional_fee,
        active: @active
      )
    end

    def process_self_overlapping!
      @contract.update!(active: false) if surrounding_contracts_exist?
    end

    def surrounding_contracts_exist?
      Contract.where.not(id: @contract.id)
        .where(number: @number)
        .where(%[start_date <= ?], @start_date)
        .where(%[(end_date IS NULL OR end_date >= ?)], @end_date)
        .exists?
    end

    def process_overlapping
      overlapping_contracts = Contract.where.not(id: @contract.id)
        .where(number: @number)
        .where(%[start_date >= ?], @start_date)

      if @end_date.present?
        overlapping_contracts.where(%[end_date <= ?], @end_date).update_all(active: false)
      else
        overlapping_contracts.update_all(active: false)
      end
    end
  end
end
