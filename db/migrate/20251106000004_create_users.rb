class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.references :account, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
