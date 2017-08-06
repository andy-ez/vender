module VendingMachineParts
  # Encapsulation of calculations and logic for the machine.
  # Stores the current selection, amount of change due and
  # the and the current state of operation.
  class Calculator
    attr_reader :selection, :status, :change, :cash_register, :products
    private :cash_register, :products
    def initialize(cash_register, product_container)
      @cash_register = cash_register
      @products = product_container
      @status = :idle
      @change = Components::CoinCollection.new
    end

    def process_transaction
      return unless selection
      if shortfall > 0
        @status = :in_progress
      elsif shortfall.zero?
        @status = :success
      else
        calculate_change(shortfall * -1)
      end
      [:success, :in_progress].include?(status)
    end

    # Returns product and sets the selection if idle and is passed
    # an avilable product name. Returns error message otherwise.
    def set_product(product_name)
      if can_select_product?(product_name)
        @selection = product_from_name(product_name)
      else
        get_selection_error(product_name)
      end
    end

    def idle?
      status == :idle
    end

    def reset
      @change = Components::CoinCollection.new
      @selection = nil
      @status = :idle
    end

    def shortfall
      selection.value - money_paid.total_value if selection
    end

    def money_paid
      cash_register.money_paid
    end

    private

    # recurssive check for available change
    def calculate_change(amount, coin_array = nil)
      # ignore coins higher than the target amount
      @status = :no_change
      avail_coins = get_available_coins(coin_array, amount)
      return status unless avail_coins.any?
      required_quantity = amount / avail_coins[0].value
      return status unless coins_are_available(avail_coins, required_quantity)
      residual = amount % avail_coins[0].value
      return @status = :success if residual.zero?
      calculate_change(residual, avail_coins[1..-1])
    end

    def get_available_coins(coin_array, amount)
      if coin_array
        coin_array
      else
        cash_register.available_coins.select { |coin| coin.value <= amount }
      end
    end

    # checks if the coins are available and if so adds it to
    # the change due back. Else it resets change due and
    # calls calculate_change with an empty array to return
    # correct status
    def coins_are_available(avail_coins, required_quantity)
      if cash_register.coins[avail_coins[0].name] >= required_quantity
        change.add_coins(avail_coins[0].name, required_quantity)
      else
        reset_change
        false
      end
    end

    def can_select_product?(product_name)
      idle? && product_is_available?(product_name)
    end

    def product_is_available?(product_name)
      products.available_products.keys.include?(product_name)
    end

    def product_from_name(name)
      products.product_from_name(name)
    end

    def get_selection_error(name)
      if !idle?
        'A transaction is already in Progress'
      else
        "#{name} is not available"
      end
    end

    def reset_change
      @change = Components::CoinCollection.new
    end
  end
end
