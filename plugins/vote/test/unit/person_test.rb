require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  should 'vote in a comment with value greater than 1' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote(comment, 5)
    assert_equal 1, person.vote_count
    assert_equal 5, person.votes.first.vote
    assert person.voted_on?(comment)
  end

  should 'vote in a comment with value lesser than -1' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote(comment, -5)
    assert_equal 1, person.vote_count
    assert_equal -5, person.votes.first.vote
  end

  should 'vote for a comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    assert !person.voted_for?(comment)
    person.vote_for(comment)
    assert person.voted_for?(comment)
    assert !person.voted_against?(comment)
  end

  should 'vote against a comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    assert !person.voted_against?(comment)
    person.vote_against(comment)
    assert !person.voted_for?(comment)
    assert person.voted_against?(comment)
  end

  should 'do not vote against a comment twice' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    assert person.vote_against(comment)
    assert !person.vote_against(comment)
  end

  should 'do not vote for a comment twice' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    assert person.vote_for(comment)
    assert !person.vote_for(comment)
  end

  should 'not vote against a voted for comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote_for(comment)
    person.vote_against(comment)
    assert person.voted_for?(comment)
    assert !person.voted_against?(comment)
  end

  should 'not vote for a voted against comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote_against(comment)
    person.vote_for(comment)
    assert !person.voted_for?(comment)
    assert person.voted_against?(comment)
  end

  should 'undo a vote for a comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote_for(comment)
    assert person.voted_for?(comment)
    person.votes.for_voteable(comment).destroy_all
    assert !person.voted_for?(comment)
  end

  should 'count comments voted' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    comment2 = fast_create(Comment)
    comment3 = fast_create(Comment)
    person.vote_for(comment)
    person.vote_for(comment2)
    person.vote_against(comment3)
    assert_equal 3, person.vote_count
    assert_equal 2, person.vote_count(true)
    assert_equal 1, person.vote_count(false)
  end

  should 'vote in a article with value greater than 1' do
    article = fast_create(Article)
    person = fast_create(Person)

    person.vote(article, 5)
    assert_equal 1, person.vote_count
    assert_equal 5, person.votes.first.vote
    assert person.voted_on?(article)
  end

  should 'vote for a article' do
    article = fast_create(Article)
    person = fast_create(Person)

    assert !person.voted_for?(article)
    person.vote_for(article)
    assert person.voted_for?(article)
    assert !person.voted_against?(article)
  end

  should 'vote against a article' do
    article = fast_create(Article)
    person = fast_create(Person)

    assert !person.voted_against?(article)
    person.vote_against(article)
    assert !person.voted_for?(article)
    assert person.voted_against?(article)
  end

end
