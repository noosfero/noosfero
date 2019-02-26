require_relative '../spec_helper'

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

  describe '.switch_orders' do
    let!(:p) { fast_create(Person) }
    let!(:article5) { fast_create(Article, position: 0, profile_id: p.id) }
    let!(:article4) { fast_create(Article, position: 0, profile_id: p.id) }
    let!(:article3) { fast_create(Article, position: 0, profile_id: p.id) }
    let!(:article2) { fast_create(Article, position: 3, profile_id: p.id) }
    let!(:article1) { fast_create(Article, position: 4, profile_id: p.id) }
    let!(:other_article) { fast_create(Article, position: 1) }

    context 'moving between orders' do
      before do
        Article.switch_orders(article2, article3)
        article1.reload
        article2.reload
        article3.reload
        article4.reload
        article5.reload
        other_article.reload
      end

      it { expect(article1.position).to eq(5) }
      it { expect(article3.position).to eq(4) }
      it { expect(article2.position).to eq(3) }
      it { expect(article4.position).to eq(0) }
      it { expect(article5.position).to eq(0) }
      it { expect(other_article.position).to eq(1) }
    end

    context 'moving on the same order' do
      before do
        Article.switch_orders(article3, article4)
        article1.reload
        article2.reload
        article3.reload
        article4.reload
        article5.reload
        other_article.reload
      end

      it { expect(article1.position).to eq(5) }
      it { expect(article2.position).to eq(4) }
      it { expect(article4.position).to eq(1) }
      it { expect(article3.position).to eq(0) }
      it { expect(article5.position).to eq(0) }
      it { expect(other_article.position).to eq(1) }
    end
  end
end
