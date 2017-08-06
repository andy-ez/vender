module Components
  # Collection class for coins
  class CoinCollection
    extend Forwardable
    attr_accessor :coins
    def_delegators :@coins, :[], :[]=, :each, :keys, :values, :select
    class InsufficientCoinsError < StandardError; end

    def initialize(coins_hash = {})
      @coins = coin_hash(coins_hash)
    end

    def +(other)
      result = CoinCollection.new
      result.coins = coins.merge(other.coins) do |key, value|
        value + other.coins[key]
      end
      result
    end

    def -(other)
      new_collection = CoinCollection.new
      new_collection.coins = coins.merge(other.coins) do |key, value|
        result = value - other.coins[key]
        raise InsufficientCoinsError, 'Not enough coins to do that.' if result < 0
        result
      end
      new_collection
    end

    def add_coins(coin_name, quantity)
      coin = valid_coin_entry(coin_name, quantity)
      coins[coin.name] += quantity
    end

    def remove_coins(coin_name, quantity)
      coin = valid_coin_entry(coin_name, quantity)
      handle_insufficient_coins(coin.name) if quantity > coins[coin.name]
      coins[coin.name] -= quantity
    end

    # returns total value (in pence) of coins in the collection
    def total_value
      coins.reduce(0) do |sum, (coin_name, quantity)|
        sum + coin_value(coin_name) * quantity
      end
    end

    def ==(other)
      coins == other.coins
    end

    def empty?
      coins.values.none? { |quantity| quantity > 0 }
    end

    def clear!
      self.coins = empty_coin_hash
    end

    private

    def coin_value(coin_name)
      Components::Coin::COIN_VALUES[coin_name]
    end

    def valid_coin_entry(coin_name, quantity)
      handle_negative_quantity unless quantity > 0
      Components::Coin.new(coin_name)
    end

    def handle_insufficient_coins(coin)
      raise(InsufficientCoinsError, "Not enough #{coin} coins to do that")
    end

    def handle_negative_quantity
      raise(ArgumentError, 'Quantity must be a positive number')
    end

    def coin_hash(coins_hash = {})
      Components::Coin::ACCEPTED_COINS.each_with_object({}) do |coin_name, hash|
        hash[coin_name] = coins_hash[coin_name] || 0
      end
    end

    def empty_coin_hash
      coin_hash
    end
  end
end
