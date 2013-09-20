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
    this.resetSelected()
    window.data = @_data
    window.selected = @_selected

  # is the product available or is out-of-stock?
  isAvailable: (type_id, value_id) ->
    available_variants = for variant_id, variant of @_data[type_id][value_id]
      variant_id if variant.count > 0
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
      return @_selectable_variants[0]


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
    for type_id, useless of @_data
      @_selected[type_id] = 0


$ ->
  $('[data-variant-options]').each ->
    variants = new VariantOptions($(@).data('variant-options'))

    $('[data-variant-option-value]').each ->
      type_id = $(@).data('variant-option-type')
      value_id = $(@).data('variant-option-value')
      if true # variants.isAvailable(type_id, value_id) # FIXME

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
