class AddUserIdToSession < ActiveRecord::Migration

  def change
    add_column :sessions, :user_id, :integer
    add_index :sessions, :user_id
  end

  def up
    Session.reset_column_information

    # cleanup data: {}
    Session.where(data: "BAh7AA==\n").delete_all
    # cleanup data with lang key only
    Session.where("data ~ 'BAh7BjoJbGFuZyIH.{3,3}=\n'").delete_all

    # very slow migration, only do for the last month
    Session.where('updated_at > ?', 1.month.ago).find_each batch_size: 50 do |session|
      begin
        # this calls Session#copy_to_columns
        session.save!
      rescue ArgumentError
        # old ActionController::Flash::FlashHash from rails 2.3
        session.destroy
      end

      # limit limitless allocations
      GC.start
    end
  end

end
