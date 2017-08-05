require_relative '../../lib/components/coin'

RSpec.describe Components::Coin do
  context 'initialized with a valid amount' do
    it 'has a public name instance variable set' do
      expect(described_class.new('20p').name).to eq('20p')
    end

    it 'has a public value instance variable set to the coin value in pence' do
      expect(described_class.new('£2').value).to eq(200)
    end
  end

  context 'initialized with an invalid amount' do
    it 'raises an arguement error' do
      expect { described_class.new('21p') }.to raise_error(ArgumentError)
    end
  end
end
