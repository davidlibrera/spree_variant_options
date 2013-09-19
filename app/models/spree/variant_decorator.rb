Spree::Variant.class_eval do

  include ActionView::Helpers::NumberHelper

  attr_accessible :option_values

  def to_hash
    {
      :id    => self.id,
      :count => self.total_on_hand,
      :price => number_to_currency(self.price),
    }
  end

end
