module VendingMachineParts
  # Container for all the coins & their quantities in the vending machine
  # grouped by denomination
  # Assumes unbounded space for storing coins
  class CashRegister
    extend Forwardable
    attr_reader :coins, :money_paid
    def_delegators :@coins, :add_coins, :remove_coins, :total_value, :empty?, :clear!
    def initialize
      @coins = Components::CoinCollection.new
      @money_paid = Components::CoinCollection.new
    end

    def add_payment(coin, quantity=1)
      money_paid.add_coins(coin, quantity)
    end

    def pay_out_change(change)
      @coins -= change
    end

    def return_money_paid
      return_amount = @money_paid.total_value
      @money_paid = Components::CoinCollection.new
      return_amount
    end

    def release_money_paid
      @coins += money_paid
      @money_paid = Components::CoinCollection.new
    end

    # returns values of the available coins in descending order
    def available_coins
      coins.select { |coin, quantity| quantity > 0 }.keys
        .map { |coin| Components::Coin.new(coin) }
        .reverse
    end

    def fill_register(quantity_per_coin=20)
      coins.each do |coin_name, quantity|
        coins[coin_name] = quantity_per_coin
      end
    end
  end
end
