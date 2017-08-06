RSpec.describe VendingMachineParts::CashRegister do
  let(:new_register) { described_class.new }

  describe '#initialize' do
    it 'creates a new register with public money_paid ivar set to an empty coin collection' do
      expect(new_register.coins)
        .to eq(Components::CoinCollection.new)
    end

    context 'with no arguments' do
      it 'creates a new register with public coins ivar set to an empty coin collection' do
        expect(new_register.coins)
          .to eq(Components::CoinCollection.new)
      end
    end

    context 'with an initial coins hash' do
      it 'sets the quantities passed in from the hash' do
        coins = { '£1' => 10, '5p' => 3 }
        new_loaded_register = described_class.new(coins)
        expect(new_loaded_register.coins)
          .to eq(Components::CoinCollection.new(coins))
      end
    end
  end

  describe '#add_coins' do
    it 'sends the add coins message to the coin collection' do
      expect(new_register.coins).to receive(:add_coins)
      new_register.add_coins('20p', 20)
    end
  end

  describe '#remove_coins' do
    it 'sends the remove coins message to the coin collection' do
      expect(new_register.coins).to receive(:remove_coins)
      new_register.remove_coins('20p', 20)
    end
  end

  describe '#total_value' do
    it 'sends the total_value message to the coin collection' do
      expect(new_register.coins).to receive(:total_value)
      new_register.total_value
    end
  end

  describe '#empty?' do
    it 'sends the empty? message to the coin collection' do
      expect(new_register.coins).to receive(:empty?)
      new_register.empty?
    end
  end

  describe '#clear!' do
    it 'sends the clear! message to the coin collection' do
      expect(new_register.coins).to receive(:clear!)
      new_register.clear!
    end
  end

  describe '#fill_register' do
    it 'sets the quantity of each coin in the register to 20 when no argument' do
      new_register.fill_register
      expect(new_register.coins.values).to eq([20] * 8)
    end

    it 'sets the quantity of each coin in the register to supplied argument' do
      new_register.fill_register(50)
      expect(new_register.coins.values).to eq([50] * 8)
    end
  end
end
