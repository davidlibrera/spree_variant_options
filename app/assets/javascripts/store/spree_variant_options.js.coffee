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

  cleanRow: (type_id) ->
    $("[data-variant-option-type='#{type_id}']").each ->
      $(this).removeClass 'selected'
      $(this).removeClass 'locked'

  evaluateRow: (type_id) ->
    $("[data-variant-option-type='#{type_id}']").each (i, el) =>
      value_id = $(el).data('variant-option-value')
      $.extend selected, @_selected
      selected[type_id] = value_id
      if @isAvailable selected
        $(el).removeClass 'locked'
      else
        $(el).addClass 'locked'

      $(el).removeClass 'selected' if @isSelected selected

  evaluateRows: (skip_type_id) ->
    @evaluateRow type_id for type_id, value_id of @_selected when type_id.toString() isnt skip_type_id.toString()

  select: (type_id, value_id) ->
    @_selected[type_id] = value_id

  unselect: (type_id) ->
    @_selected[type_id] = 0

  isAvailable: (selected) ->
    keys = $.grep $.keys(selected), (item) -> selected[item] != 0
    available_products = $.grep @_data, (item) ->
      available = true
      available = available && item[key] == selected[key] for key in keys
      available
    available_products.length > 0
##########################################################################################


  # is the product available or is out-of-stock?
  oldIsAvailable: (type_id, value_id) ->
    available_variants = $.grep @_data, (elem) ->
      available = true
      available = (available && elem[type_id] == value_id)
      ((available && elem[other_type_id] == other_value_id) || other_value_id == 0) for other_type_id, other_value_id of @_selected
      available
    true if available_variants.length > 0

  # returns the selected variants if all options are chosen
  toggle: (type_id, value_id) ->
    @_selected[type_id] = if this.isSelected(type_id, value_id) then 0 else value_id
    selected_types_count = 0
    @_selectable_variants = undefined
    for selected_type, selected_value of @_selected
      if selected_value != 0
        selected_types_count++
        @_selectable_variants ?= $.keys(@_data[selected_type][selected_value])
        @_selectable_variants = $.intersect @_selectable_variants, $.keys(@_data[selected_type][selected_value])
    if @_selectable_variants && @_selectable_variants.length == 1 && $.keys(@_selected).length == selected_types_count
      @_selectable_variants[0]


  isSelected: (type_id, value_id) ->
    (@_selected[type_id] == value_id)

  isSelectable: (type_id, value_id) ->
    selectable = false
    return true unless @_selectable_variants
    for selected_type, selected_value of @_selected
      if selected_value != 0
        for key in $.keys(@_data[type_id][value_id])
          selectable |= (key in @_selectable_variants)
    selectable

  resetSelected: ->
    @_selected[type_id] = 0 for type_id in @_opt_ids

$ ->
  $('[data-variant-options]').each ->
    variants = new VariantOptions($(@).data('variant-options'))
    $('[data-variant-option-value]').each ->
      type_id = $(@).data('variant-option-type')
      value_id = $(@).data('variant-option-value')
      $(@).click ->
        if $(@).hasClass 'selected'
          variants.unselect type_id
          $(@).removeClass 'selected'
        else
          variants.cleanRow type_id
          variants.select type_id, value_id
          $(@).addClass 'selected'
        variants.evaluateRows(type_id)
      ###
      if variants.isAvailable(type_id, value_id)

        $(@).click ->
          unless $(@).hasClass('locked')
            $("[data-variant-option-value]").removeClass 'selected'
            variant = variants.toggle(type_id, value_id)
            # $(@).addClass('selected') if variants.isSelected(type_id, value_id)

            $("[data-variant-option-value]").each ->
              type_id_new = $(@).data('variant-option-type')
              value_id_new = $(@).data('variant-option-value')
              $(@).toggleClass 'selected', variants.isSelected(type_id_new, value_id_new)
              $(@).toggleClass 'locked', !variants.isSelectable(type_id_new, value_id_new)
            if variant?
              $("input#variant_id").val(variant)
              $('#add-to-cart-button').removeClass('disabled')
              console.log "FIXME: chosen", variant
            else
              $("input#variant_id").val()
              $('#add-to-cart-button').addClass('disabled')
          false

      else
        $(@).addClass('out-of-stock')
      ###
