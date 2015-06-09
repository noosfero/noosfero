class CreateEmailTemplate < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :name
      t.string :template_type
      t.string :subject
      t.text :body
      t.references :owner, :polymorphic => true
      t.timestamps
    end
  end
end
