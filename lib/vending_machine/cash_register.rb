require_relative '../components/coin_collection'

module VendingMachine
  # Container for all the coins & their quantities in the vending machine
  # grouped by denomination
  # Assumes unbounded space for storing coins
  class CashRegister
    extend Forwardable
    attr_reader :coins
    def_delegators :@coins, :add_coins, :remove_coins, :total_value, :empty?, :clear!
    def initialize
      @coins = Components::CoinCollection.new
    end
  end
end
