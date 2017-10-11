# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :author_books, dependent: :destroy
  has_many :authors, through: :author_books
  has_many :reviews, dependent: :destroy
  belongs_to :category
  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true

  validates :title, :price, :description,
            :published_at, :height, :weight, :depth,
            :materials, :category_id, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :height, :weight, :depth, numericality: { only_float: true }
  validates :published_at, numericality: {
                             greater_than_or_equal_to: 1900,
                             less_than_or_equal_to: Time.now.year
                           }
  validates :title, uniqueness: true
  validates_length_of :title, maximum: 120
  validates_length_of :materials, maximum: 80
  validates_length_of :description, in: 5..2000

  accepts_nested_attributes_for :images, allow_destroy: true

  scope :best_sellers, -> { sold_books.group_by(&:type_of).each_value{ |v| v.max_by(&:summed_items) }.map{ |_, v| v.first } }
  scope :latest, -> { includes(:authors).last 3 }

  def self.by_category(cat_id)
    cat_id ? where('category_id = ?', cat_id) : unscoped
  end

  private

  def self.sold_books
    Book.find_by_sql("SELECT categories.type_of, books.*,
      SUM(cartify_order_items.quantity) AS summed_items FROM books
      INNER JOIN cartify_order_items ON cartify_order_items.product_id = books.id
      INNER JOIN cartify_orders ON cartify_orders.id = cartify_order_items.order_id
      INNER JOIN cartify_order_statuses ON cartify_order_statuses.id = cartify_orders.order_status_id
      INNER JOIN categories ON categories.id = books.category_id
      WHERE cartify_order_statuses.name = 'delivered'
      GROUP BY books.id, categories.type_of
      ORDER BY summed_items DESC")
  end
end
