class NormalizeUsersEmail < ActiveRecord::Migration
  def up
    User.find_each do |u|
      u.update_column :email, u.send(:normalize_email)
    end
  end

  def down
    say "this migration can't be reverted"
  end
end
