class CreateMailingSents < ActiveRecord::Migration
  def self.up
    create_table :mailing_sents do |t|
      t.references :mailing
      t.references :person
      t.timestamps
    end
  end

  def self.down
    drop_table :mailing_sents
  end
end
