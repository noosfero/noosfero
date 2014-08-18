class FillInAuthorNameOnSubmission < ActiveRecord::Migration
  def up
    CustomFormsPlugin::Submission.find_each do |submission|
      unless submission.profile.nil?
        submission.author_name = submission.profile.name
        submission.save
      end
    end
  end

  def down
    CustomFormsPlugin::Submission.find_each do |submission|
      unless submission.profile.nil?
        submission.author_name = nil
        submission.save
      end
    end
  end
end
