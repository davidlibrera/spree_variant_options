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

  def has_option_value?(option_value_id)
    self.option_values.map(&:id).include? option_value_id
  end

  def options_json
    values = self.option_values.joins(:option_type).order("#{Spree::OptionType.table_name}.position asc")
    opts = {}
    values.map! do |ov|
      opts[ov.option_type_id] = ov.id
    end
    opts.to_json
  end
end
