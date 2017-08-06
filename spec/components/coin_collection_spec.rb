RSpec.describe Components::CoinCollection do
  let(:empty_collection) do
    {
      '1p' => 0,
      '2p' => 0,
      '5p' => 0,
      '10p' => 0,
      '20p' => 0,
      '50p' => 0,
      '£1' => 0,
      '£2' => 0
    }
  end
  let(:new_coins) { described_class.new }

  describe '#initialize' do
    it 'creates a new coin collection with public coins ivar set to a hash with quantities for coins' do
      expect(new_coins.coins).to eq(empty_collection)
    end
  end

  describe '#add_coins' do
    context 'with valid input' do
      it 'adds the quantity of the coin to the collection' do
        new_coins.add_coins('£1', 20)
        expect(new_coins.coins['£1']).to eq(20)
      end

      it 'adds the quantity to the correct coin only' do
        new_coins.add_coins('£1', 20)
        expect(new_coins.coins['20p']).to eq(0)
      end
    end

    context 'with invalid coin input' do
      it 'raises an invalid argument error' do
        expect { new_coins.add_coins('0.9p', 20) }
          .to raise_error(ArgumentError)
      end
    end

    context 'with invalid quantity' do
      it 'raises an invalid argument error' do
        expect { new_coins.add_coins('20p', -2) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#remove_coins' do
    context 'with valid input' do
      it 'removes the quantity of the coin from the collection' do
        new_coins.add_coins('£1', 20)
        new_coins.remove_coins('£1', 20)
        expect(new_coins.coins['£1']).to eq(0)
      end
    end

    context 'with insufficient coins' do
      it 'raises an insufficient coins error' do
        expect { new_coins.remove_coins('£1', 20) }
          .to raise_error(Components::CoinCollection::InsufficientCoinsError)
      end
    end

    context 'with invalid coin input' do
      it 'raises an invalid argument error' do
        expect { new_coins.remove_coins('0.9p', 20) }
          .to raise_error(ArgumentError)
      end
    end

    context 'with invalid quantity' do
      it 'raises an invalid argument error' do
        expect { new_coins.remove_coins('20p', -2) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#total_value' do
    it 'returns 0 for an empty collection' do
      expect(new_coins.total_value).to eq(0)
    end

    it 'returns the monetary value in pence of all coins' do
      new_coins.add_coins('£1', 20)
      expect(new_coins.total_value).to eq(2000)
    end
  end

  describe '#empty?' do
    it 'should return true if the collection is empty' do
      expect(new_coins.empty?).to be true
    end

    it 'should return false if some coins are present' do
      new_coins.add_coins('20p', 10)
      expect(new_coins.empty?).to be false
    end
  end

  describe '#clear!' do
    it 'resets the coins iVar to be an empty collection' do
      new_coins.add_coins('20p', 100)
      new_coins.clear!
      expect(new_coins.coins).to eq(empty_collection)
    end
  end
end
