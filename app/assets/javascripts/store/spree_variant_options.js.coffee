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
    @data = data
    @selected = {}
    @selectable_variants = undefined
    this.resetSelected()

  # is the product available or is out-of-stock?
  isAvailable: (type_id, value_id) ->
    available_variants = for variant_id, variant of @data[type_id][value_id]
      variant_id if variant.count > 0
    true if available_variants.length > 0

  toggle: (type_id, value_id) ->
    @selected[type_id] = value_id
    selected_types_count = 0
    @selectable_variants = undefined
    for selected_type, selected_value of @selected
      if selected_value != 0
        selected_types_count++
        @selectable_variants ?= $.keys(@data[selected_type][selected_value])
        @selectable_variants = $.intersect @selectable_variants, $.keys(@data[selected_type][selected_value])
    if @selectable_variants && @selectable_variants.length == 1 && $.keys(@selected).length == selected_types_count
      console.log "variant chosen!", @selectable_variants[0]


  isSelected: (type_id, value_id) ->
    (@selected[type_id] == value_id)

  isSelectable: (type_id, value_id) ->
    selectable = false
    return true unless @selectable_variants
    for selected_type, selected_value of @selected
      if selected_value != 0
        for key in $.keys(@data[type_id][value_id])
          selectable |= (key in @selectable_variants)
    selectable

  resetSelected: ->
    for type_id, useless of @data
      @selected[type_id] = 0


$ ->
  $('[data-variant-options]').each ->
    variants = new VariantOptions($(@).data('variant-options'))

    $('[data-variant-option-value]').each ->
      type_id = $(@).data('variant-option-type')
      value_id = $(@).data('variant-option-value')
      if true # variants.isAvailable(type_id, value_id)

        $(@).click ->
          return false if $(@).hasClass('locked')
          unless variants.isSelected(type_id, value_id)
            $("[data-variant-option-value][data-variant-option-type='#{type_id}']").removeClass 'selected'
            variants.toggle(type_id, value_id)
            $(@).addClass 'selected'
            $(@).parent().parent().find('[data-clear]').show()

            $('[data-variant-option-value]').each ->
              $(@).toggleClass 'locked', !variants.isSelectable($(@).data('variant-option-type'), $(@).data('variant-option-value'))
          false

      else
        $(@).addClass('out-of-stock')

    $(@).find('[data-clear]').click ->
      type_id = $(@).data('variant-option-type')
      $("[data-variant-option-value][data-variant-option-type='#{type_id}']").removeClass 'selected'
      variants.toggle(type_id, 0)
      $('[data-variant-option-value]').each ->
        $(@).toggleClass 'locked', !variants.isSelectable($(@).data('variant-option-type'), $(@).data('variant-option-value'))
      $(@).hide()
      false
