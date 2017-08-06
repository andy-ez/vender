RSpec.describe Components::Product do
  context 'initialized with a valid price' do
    it 'has a public name instance variable set' do
      expect(described_class.new('Snickers', 10).name).to eq('Snickers')
    end

    it 'has a public value instance variable set' do
      expect(described_class.new('Snickers', 10).value).to eq(10)
    end
  end

  context 'initialized with an invalid price' do
    it 'raises an arguement error' do
      expect { described_class.new('Snickers', -21) }.to raise_error(ArgumentError)
    end
  end
end
