require 'spec_helper'

describe Article do
  it_behaves_like "having metadata"

  context 'callbacks' do
    describe '#set_position' do
      let(:profile) { fast_create(Person) }
      let(:attrs) { defaults_for_article.except(:path, :profile_id) }
      let!(:article1) { fast_create(Article, position: 1, profile_id: profile.id) }
      let!(:article2) { fast_create(Article, position: 2, profile_id: profile.id) }
      let!(:article3) { fast_create(Article, position: 3) }

      before do
      end

      it 'sets the next order if it is nil' do
        article = profile.articles.create! attrs
        expect(article.position).to eq(3)
      end

      it 'not overrides the article order if it was set' do
        article = profile.articles.create! attrs.merge(position: 1)
        expect(article.position).to eq(1)
      end

      it 'changes articles order if a new article with position is added' do
        article = profile.articles.create! attrs.merge(position: 1)
        article1.reload
        article2.reload
        expect(article1.position).to eq(2)
        expect(article2.position).to eq(3)
      end

    end
  end

end
