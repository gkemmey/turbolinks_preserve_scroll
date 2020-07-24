class CreateEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :emails do |t|
      t.string :subject
      t.text :message
      t.integer :predictably

      t.timestamps
    end
  end
end
