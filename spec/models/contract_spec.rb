RSpec.describe Contract, type: :model do
  # We could use some one-liners like Shoulda Matchers,
  # but I prefer to test edge cases explicitly
  # without additional dependency
  describe 'validations' do
    context 'valid attributes' do
      subject { build(:contract) }

      it 'should be valid' do
        expect(subject).to be_valid
      end
    end

    context 'when fixed_fee is not a number' do
      subject { build(:contract, fixed_fee: 'one percent') }

      it 'should be invalid' do
        expect(subject).to be_invalid
      end
    end

    context 'when fixed_fee is negative' do
      subject { build(:contract, fixed_fee: -0.1) }

      it 'should be invalid' do
        expect(subject).to be_invalid
      end
    end

    context 'when days_included is not a number' do
      subject { build(:contract, days_included: 'seven') }

      it 'should be invalid' do
        expect(subject).to be_invalid
      end
    end

    context 'when days_included is negative' do
      subject { build(:contract, days_included: -1) }

      it 'should be invalid' do
        expect(subject).to be_invalid
      end
    end

    context 'when days_included not an integer' do
      subject { build(:contract, days_included: 1.5) }

      it 'should be invalid' do
        expect(subject).to be_invalid
      end
    end
  end
end
