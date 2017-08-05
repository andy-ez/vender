require_relative '../../lib/vending_machine/cash_register'

RSpec.describe VendingMachine::CashRegister do
  let(:new_register) { described_class.new }

  describe '#initialize' do
    it 'creates a new register with public coins ivar set to an empty coin collection' do
      expect(new_register.coins)
        .to eq(Components::CoinCollection.new)
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
end
