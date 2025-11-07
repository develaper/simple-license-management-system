class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :account, null: false, type: :uuid
      t.references :product, null: false, type: :uuid
      t.integer :number_of_licenses, null: false
      t.datetime :issued_at, null: false
      t.datetime :expires_at, null: false

      t.timestamps

      t.check_constraint "number_of_licenses > 0", name: "check_positive_licenses"
      t.index [ :account_id, :product_id ], unique: true, name: "index_subscriptions_on_account_and_product"
    end

    add_foreign_key :subscriptions, :accounts
    add_foreign_key :subscriptions, :products
  end
end
