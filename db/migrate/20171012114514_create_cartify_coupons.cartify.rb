# This migration comes from cartify (originally 20171005130857)
class CreateCartifyCoupons < ActiveRecord::Migration[5.1]
  def change
    create_table :cartify_coupons do |t|
      t.string :name
      t.decimal :value, precision: 8, scale: 2
    end
  end
end
