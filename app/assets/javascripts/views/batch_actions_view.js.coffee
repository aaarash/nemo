#// Models the batch actions done on index pages
class ELMO.Views.BatchActionsView extends ELMO.Views.ApplicationView

  el: '#index_table'

  events:
    'click #select_all_link': 'select_all_clicked'
    'click a.batch_op_link': 'submit_batch'
    'click a.select_all_rows': 'select_all_rows'
    'change input[type=checkbox].batch_op': 'checkbox_changed'
    'mouseover table.index_table tbody tr': 'highlight_partner_row'
    'mouseout table.index_table tbody tr': 'unhighlight_partner_row'

  initialize: (params, search_form_view) ->
    @is_search = params.is_search
    @form = this.$el.find('form').first() || this.$el.closest('form')
    @select_all_rows_field = this.$el.find('input[name=select_all]')
    @alert = this.$el.find('div.alert')
    @pages = this.$el.data('pages')
    @entries = this.$el.data('entries')
    @select_all_page = false
    @class_name = I18n.t("activerecord.models.#{params.class_name}.many")
    @search_form_view = search_form_view

    # flash the modified obj if given
    if params.modified_obj_id
      $('#' + params.class_name + '_' + params.modified_obj_id).effect("highlight", {}, 1000)

    # sync state of select all link
    if params.batch_ops
      this.update_select_all_elements()


  # selects/deselects all boxes on page
  select_all_clicked: (event) ->
    event.preventDefault() if event

    cbs = this.get_batch_checkboxes()

    @select_all_page = !@select_all_page

    # toggle select all rows parameter
    if @select_all_rows_field.val()
      @select_all_rows_field.val('')

    # check/uncheck boxes
    cb.checked = @select_all_page for cb in cbs

    # update select all view elements
    this.update_select_all_elements()

    return false

  # tests if all boxes are checked
  all_checked: (cbs = this.get_batch_checkboxes()) ->
    _.all(cbs, (cb) -> cb.checked)

  select_all_rows: ->
    value = if @select_all_rows_field.val() then '' else '1'
    @select_all_rows_field.val(value)
    this.reset_alert()
    msg = I18n.t("index_table.messages.selected_all_rows", {count: @entries, class_name: @class_name})
    @alert.html(msg)
    @alert.addClass('alert-info').show()

  # reset the alert element
  reset_alert: ->
    @alert.stop().hide().
      removeClass('alert-danger alert-info alert-warning alert-success').removeAttr('opacity')

  # updates the select all link to reflect the select_all field
  update_select_all_elements: ->
    label = if @select_all_page then "deselect_all" else "select_all"
    $('#select_all_link').html(I18n.t("layout.#{label}"))

    this.reset_alert()

    if @pages > 1 and @select_all_page
      msg = I18n.t("index_table.messages.selected_rows_page", {count: this.get_selected_count()}) + " " +
        "<a href='#' class='select_all_rows'>" +
        I18n.t("index_table.messages.select_all_rows", {class_name: @class_name, count: @entries}) +
        "</a>"
      @alert.html(msg)
      @alert.addClass('alert-info').show()

  # gets all checkboxes in batch_form
  get_batch_checkboxes: ->
    @form.find('input[type=checkbox].batch_op')

  get_selected_count: ->
    if @select_all_rows_field.val()
      @entries
    else
      _.size(_.filter(this.get_batch_checkboxes(), (cb) -> cb.checked))

  get_selected_items: ->
    @form.find('input.batch_op:checked')

  # event handler for when a checkbox is clicked
  checkbox_changed: (event) ->
    # unset the select all field if a checkbox is changed in any way
    @select_all_rows_field.val('')

    # change text of link if all checked
    this.update_select_all_elements()

  # submits the batch form to the given path
  submit_batch: (event) ->
    event.preventDefault()

    options = $(event.target).data()

    # ensure there is at least one item selected, and error if not
    selected = this.get_selected_count()
    if selected == 0
      @alert.html(I18n.t("layout.no_selection")).addClass('alert-danger').show()
      @alert.delay(2500).fadeOut('slow', this.reset_alert.bind(this))

    # else, show confirm dialog (if requested), and proceed if 'yes' clicked
    else if not options.confirm or confirm(I18n.t(options.confirm, {count: selected}))

      # construct a temporary form
      form = $('<form>').attr('action', options.path).attr('method', 'post').attr('style', 'display: none')

      # copy the checked checkboxes to it, along with the select_all field
      # (we do it this way in case the main form has other stuff in it that we don't want to submit)
      form.append(@form.find('input.batch_op:checked').clone())
      form.append(@form.find('input[name=select_all]').clone())
      form.append(@search_form_view.$el.find('input[name=search]').clone())

      token = $('meta[name="csrf-token"]').attr('content')
      $('<input>').attr({type: 'hidden', name: 'authenticity_token', value: token}).appendTo(form)

      # need to append form to body before submitting
      form.appendTo($('body'))

      # submit the form
      form.submit()

    return false