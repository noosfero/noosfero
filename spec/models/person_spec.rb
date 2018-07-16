require 'spec_helper'

describe Person do
  describe '#display_private_info_to?' do
    let(:person) { fast_create(Person) }
    let(:other_person) { fast_create(Person) }

    it { expect(person.display_private_info_to?(nil)).to eq(false) }
    it { expect(person.display_private_info_to?(other_person)).to eq(false) }
    it { expect(person.display_private_info_to?(person)).to eq(true) }

    context 'other person is admin' do
      before { Environment.default.add_admin(other_person) }

      it { expect(person.display_private_info_to?(other_person)).to eq(true) }
    end

    context 'other person is a friend' do
      before { person.add_friend(other_person) }

      context 'profile is visible' do
        before do
          expect(person).to receive(:display_to?)
            .with(other_person)
            .and_return(true)
        end

        it { expect(person.display_private_info_to?(other_person)).to eq(true) }
      end

      context 'profile is not visible' do
        before do
          expect(person).to receive(:display_to?)
            .with(other_person)
            .and_return(false)
        end

        it { expect(person.display_private_info_to?(other_person)).to eq(false) }
      end
    end
  end
end
