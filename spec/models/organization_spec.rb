require 'spec_helper'

describe Organization do
  describe '#display_private_info_to?' do
    let(:organization) { fast_create(Organization) }
    let(:person) { fast_create(Person) }

    it { expect(organization.display_private_info_to?(nil)).to eq(false) }
    it { expect(organization.display_private_info_to?(person)).to eq(false) }

    context 'person is an environment admin' do
      before { Environment.default.add_admin(person) }

      it { expect(organization.display_private_info_to?(person)).to eq(true) }
    end

    context 'person is a member' do
      before { organization.add_member(person) }

      context 'profile is visible' do
        before do
          expect(organization).to receive(:display_to?)
            .with(person)
            .and_return(true)
        end

        it { expect(organization.display_private_info_to?(person)).to eq(true) }
      end

      context 'profile is not visible' do
        before do
          expect(organization).to receive(:display_to?)
            .with(person)
            .and_return(false)
        end

        it { expect(organization.display_private_info_to?(person)).to eq(false) }
      end
    end
  end
end
