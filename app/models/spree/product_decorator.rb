Spree::Product.class_eval do

  def option_values
    @_option_values ||= Spree::OptionValue.for_product(self).order(:position).sort_by {|ov| ov.option_type.position }
  end

  def grouped_option_values
    @_grouped_option_values ||= option_values.group_by(&:option_type)
  end

  def variants_for_option_value(value)
    @_variant_option_values ||= variants.includes(:option_values).all
    @_variant_option_values.select { |i| i.option_value_ids.include?(value.id) }
  end

  def variant_options_hash
    return @_variant_options_hash if @_variant_options_hash
    array = []
    variants.includes(:option_values).each do |variant|
      hash = {variant_id: variant.id, count: variant.total_on_hand, price: variant.price}
      variant.option_values.each do |ov|
        hash[ov.option_type.id] = ov.id
      end
      array.push hash
    end
    @_variant_options_hash = array
  end

end
