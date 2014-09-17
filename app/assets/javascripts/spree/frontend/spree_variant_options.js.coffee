$.extend
  keys: (obj) ->
    a = []
    $.each obj, (k) -> a.push(k)
    a

$.extend
  intersect: (a, b) ->
    $.grep a, (i) -> $.inArray(i, b) > -1


class VariantOptions
  constructor: (data, options) ->
    @_data = data
    @_selected = {}
    @_selectable_variants = undefined
    @_opt_ids = $.unique $.map $('[data-variant-option-type]'), (val, i) ->
      $(val).data 'variant-option-type'
    this.resetSelected()
    window.data = @_data
    window.selected = @_selected
    window.opt_ids = @_opt_ids

  isSelected: (type_id, value_id) ->
    (@_selected[type_id] == value_id)

  select: (type_id, value_id) ->
    @unselect type_id
    @_selected[type_id] = value_id

  unselect: (type_id) ->
    @_selected[type_id] = 0

  availableProducts: (selected) ->
    keys = $.grep $.keys(selected), (item) -> selected[item] != 0
    available_products = $.grep @_data, (item) ->
      available = true
      available = available && item[key] == selected[key] for key in keys
      available

  isAvailable: (selected) ->
    @availableProducts(selected).length > 0 and !@isOutOfStock(selected)

  isOutOfStock: (selected) ->
    @availableProducts(selected)[0]["count"] <= 0

  isCompleted: ->
    selection = $.grep @_opt_ids, (item) =>
      @_selected[item] != 0
    selection.length == @_opt_ids.length and @isAvailable @_selected

  resetSelected: ->
    @_selected[type_id] = 0 for type_id in @_opt_ids

  setAddToCart: ->
    $button = $('#add-to-cart-button')
    if @isCompleted()
      variant = @availableProducts(@_selected)[0]
      $('#variant_id').val(variant['variant_id'])
      $('#add-to-cart-button').removeClass('out-of-stock')
      $('#add-to-cart-button').attr("disabled", false);
    else
      $('#add-to-cart-button').addClass('out-of-stock')
      $('#add-to-cart-button').attr("disabled", true);

  cleanSelect: (except_type_id) ->
    $('[data-variant-option-type]').each (i, opt_type) =>
      el_type_id = $(opt_type).data('variant-option-type')
      if el_type_id != except_type_id
        $(opt_type).find('option:first-child').attr('selected', 'selected')
      else
        $option = $(opt_type).find('option:selected')
        $option.html $option.attr 'value'

  updateOptions: (type_id)->
    $('[data-variant-option-type]').each (i, opt_type) =>
      el_type_id = $(opt_type).data('variant-option-type')
      $(opt_type).find('[data-variant-option-value]').each (j, opt_val) =>
        if el_type_id != type_id
          value_id = $(opt_val).data('variant-option-value')
          value = $(opt_val).attr 'value'
          selected_copy = $.extend({}, @_selected)
          selected_copy[el_type_id] = value_id
          if not @isAvailable(selected_copy)
            $(opt_val).html "#{value} (not available)"
          else
            $(opt_val).html value

  retrieveImages: ->
    images = $('#product-thumbnails li.vtmb')
    keys = $.grep $.keys(@_selected), (item) => @_selected[item] != 0
    main_image =  images.each (i, el) =>
      $(el).hide()
      data = $(el).data 'variant'
      display = if (keys.length > 0) then true else false
      display = display && (data[key] == @_selected[key]) for key in keys
      href = $(el).find('a').first().attr('href')
      if display
        $(el).show()
        $('#main-image img').attr('src', href)
      $(el).show() if display

  allLabelAvailable: (type_id) ->
    $('[data-variant-option-type]').each (i, el) ->
      $(el).find('option[data-variant-option-value]').each (i, opt_val) ->
        $(opt_val).html $(opt_val).attr('value')

$ ->
  $('[data-variant-options]').each ->
    variants = new VariantOptions($(@).data('variant-options'))
    $('[data-variant-option-type]').each (i, el) ->
      type_id = $(el).data('variant-option-type')
      $(el).change ->
        $selected_option = $(this).find('option:selected')
        value_id = $selected_option.data('variant-option-value')
        if value_id?
          variants.select type_id, value_id
        else
          variants.unselect type_id
          variants.allLabelAvailable(type_id)

        if $selected_option.text().match /not available/i
          variants.cleanSelect(type_id)
        variants.updateOptions(type_id)
        variants.retrieveImages()
        variants.setAddToCart()

    variants.setAddToCart()
