class CreateEmailTemplate < ActiveRecord::Migration[4.2]
  def change
    return if table_exists? :email_templates

    create_table :email_templates do |t|
      t.string :name
      t.string :template_type
      t.string :subject
      t.text :body
      t.references :owner, polymorphic: true
      t.timestamps
    end
  end
end
