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
    @_opt_ids = $.unique $.map $('[data-variant-option-value]'), (val, i) ->
      $(val).data 'variant-option-type'
    this.resetSelected()
    window.data = @_data
    window.selected = @_selected
    window.opt_ids = @_opt_ids

  isSelected: (type_id, value_id) ->
    (@_selected[type_id] == value_id)

  isLocked: (type_id, value_id) ->
    $("[data-variant-option-value='#{value_id}']").hasClass 'locked'

  cleanRows: ->
    @cleanRow type_id for type_id in @_opt_ids

  cleanRow: (type_id) ->
    $("[data-variant-option-type='#{type_id}']").each (i, el) =>
      @unselect type_id
      $(el).removeClass 'selected'
      $(el).removeClass 'locked'

  select: (type_id, value_id) ->
    @unselect type_id
    $("[data-variant-option-value='#{value_id}']").each (i, el) =>
      $(el).addClass 'selected'
    @_selected[type_id] = value_id

  unselect: (type_id) ->
    $("[data-variant-option-type='#{type_id}']").each (i, el) =>
      $(el).removeClass 'selected'
    @_selected[type_id] = 0

  lockRows: (skip_type_id) ->
    @lockRow type_id for type_id, value_id of @_selected when type_id.toString() isnt skip_type_id.toString()

  lockRow: (type_id) ->
    $("[data-variant-option-type='#{type_id}']").each (i, el) =>
      value_id = $(el).data('variant-option-value')
      old_value = @_selected[type_id]
      @_selected[type_id] = value_id
      if @isAvailable selected
        $(el).removeClass 'locked'
        if @isOutOfStock selected
          $(el).addClass 'out-of-stock'
        else
          $(el).removeClass 'out-of-stock'
      else
        $(el).addClass 'locked'
      @_selected[type_id] = old_value

  availableProducts: (selected) ->
    keys = $.grep $.keys(selected), (item) -> selected[item] != 0
    available_products = $.grep @_data, (item) ->
      available = true
      available = available && item[key] == selected[key] for key in keys
      available


  isAvailable: (selected) ->
    @availableProducts(selected).length > 0

  isOutOfStock: (selected) ->
    @availableProducts(selected)[0]["count"] <= 0


  isCompleted: ->
    selection = $.grep @_opt_ids, (item) =>
      @_selected[item] != 0
    selection.length == @_opt_ids.length and not @isOutOfStock @_selected

  resetSelected: ->
    @_selected[type_id] = 0 for type_id in @_opt_ids

  setAddToCart: ->
    $button = $('#add-to-cart-button')
    if @isCompleted()
      $button.removeClass('disabled')
      $button.html "Aggiungi al carrello"
    else
      $button.addClass('disabled')
      if @isOutOfStock @_selected
        $button.html "Fuori Magazzino"
      else
        $button.html "Aggiungi al carrello"


  retrieveImages: ->
    images = $('#product-thumbnails li.vtmb')
    keys = $.grep $.keys(@_selected), (item) => @_selected[item] != 0
    main_image =
    images.each (i, el) =>
      $(el).hide()
      data = $(el).data 'variant'
      display = if (keys.length > 0) then true else false
      display = display && (data[key] == @_selected[key]) for key in keys
      href = $(el).find('a').first().attr('href')
      if display
        $(el).show()
        $('#main-image img').attr('src', href)
      $(el).show() if display

$ ->
  $('[data-variant-options]').each ->
    variants = new VariantOptions($(@).data('variant-options'))
    $('#product-thumbnails li.vtmb').each (i, el) -> $(el).hide()

    $('[data-variant-option-value]').each (i, el) ->
      type_id = $(el).data('variant-option-type')
      value_id = $(el).data('variant-option-value')
      if $(el).hasClass 'selected'
        variants.select type_id, value_id
        variants.lockRows type_id

      $(el).click ->
        if variants.isLocked type_id, value_id
          variants.cleanRows()
          variants.select type_id, value_id
        else
          if variants.isSelected type_id, value_id
            variants.unselect type_id
          else
            variants.select type_id, value_id
        variants.lockRows type_id
        variants.retrieveImages()
        variants.setAddToCart()

    variants.setAddToCart()
