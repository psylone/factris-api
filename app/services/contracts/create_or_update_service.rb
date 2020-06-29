module Contracts
  class CreateOrUpdateService
    prepend BasicService

    option :number
    option :start_date
    option :fixed_fee
    option :days_included
    option :additional_fee

    # We already have default `true` value in the database,
    # but let's define it here for clarity
    option :active, default: proc { true }
    option :end_date, optional: true

    attr_reader :contract

    def call
      # Since we're using one entry point for create/update contract
      # let's try to find an existing contract
      @contract = Contract.find_or_initialize_by(
        number: @number,
        start_date: @start_date,
        end_date: @end_date
      )

      # Not sure how critical to keep atomicity of the existing active
      # contract within each period. If it's not so critical we can
      # extract processing of overlapping contracts into background job
      Contract.transaction do
        # First let's keep changes for contract:
        # it will update existing contract or
        # create a new one
        create_or_update_contract!

        # Not sure if it possible to create a new contract in case
        # when there is existing contract which surrounds it.
        # My assumption is to create a new contract and put it
        # into inactive state. The other way is to return error
        # here to the client and not create a new contract at all
        process_self_overlapping!

        # Here we find overlapping contracts and put them into
        # inactive state
        process_overlapping if @contract.active?
      end
    rescue ActiveRecord::RecordInvalid
      # This is by service strict interface design:
      # if we can't call service with success
      # we return the result (which is an instance of this class)
      # and will decide what to do on the higher level
      # (in the controller for our case)
      fail!(@contract.errors)
    end

    private

    def create_or_update_contract!
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
