module Components
  # This represents a coin with a given face and monetary value (in pence).
  # Can only be initialized with the list of valid coins.
  class Coin
    attr_reader :value, :name

    ACCEPTED_COINS = Set.new(%w[1p 2p 5p 10p 20p 50p £1 £2]).freeze
    COIN_VALUES = ACCEPTED_COINS.each_with_object({}) do |coin_name, hash|
      hash[coin_name] = coin_name =~ /p/ ? coin_name.delete('p').to_i : coin_name.delete('£').to_i * 100
    end

    def initialize(name)
      @name = name
      handle_invalid_coin if coin_is_invalid?
      @value = COIN_VALUES[name]
    end

    private

    def handle_invalid_coin
      raise(ArgumentError, 'That coin is not recognised. PLease try again')
    end

    def coin_is_invalid?
      !ACCEPTED_COINS.include?(name)
    end
  end
end
