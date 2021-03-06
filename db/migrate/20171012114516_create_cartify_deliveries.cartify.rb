# This migration comes from cartify (originally 20171005131199)
class CreateCartifyDeliveries < ActiveRecord::Migration[5.1]
  def change
    create_table :cartify_deliveries do |t|
      t.string :name
      t.string :duration
      t.decimal :price, precision: 8, scale: 2
    end
  end
end
