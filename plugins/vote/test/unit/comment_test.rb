require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  should 'vote in a comment' do
    comment = create_comment
    person = create_user('voter').person
    person.vote(comment, 5)
    assert_equal 1, comment.voters_who_voted.length
    assert_equal 5, comment.votes_total
  end

  should 'like a comment' do
    comment = create_comment
    person = create_user('voter').person
    assert !comment.voted_by?(person, true)
    person.vote_for(comment)
    assert comment.voted_by?(person, true)
    assert !comment.voted_by?(person, false)
  end

  should 'count voters for' do
    comment = create_comment
    person = create_user('voter').person
    person2 = create_user('voter2').person
    person3 = create_user('voter3').person
    person.vote_for(comment)
    person2.vote_for(comment)
    person3.vote_against(comment)
    assert_equal 2, comment.votes_for
  end

  should 'count votes againts' do
    comment = create_comment
    person = create_user('voter').person
    person2 = create_user('voter2').person
    person3 = create_user('voter3').person
    person.vote_against(comment)
    person2.vote_against(comment)
    person3.vote_for(comment)
    assert_equal 2, comment.votes_against
  end

  should 'be able to remove a voted comment' do
    comment = create_comment
    person = create_user('voter').person
    person.vote(comment, 5)
    comment.destroy
  end

  private

  def create_comment(args = {})
    owner = create_user('testuser').person
    article = create(TextileArticle, :profile_id => owner.id)
    create(Comment, { :name => 'foo', :email => 'foo@example.com', :source => article }.merge(args))
  end

end
