# frozen_string_literal: true

module ActionLinkHelper
  def translate_action(klass_or_obj, action)
    i18nk = (klass_or_obj.respond_to?(:model_name) ? klass_or_obj : klass_or_obj.class).model_name.i18n_key
    t("activerecord.action_links.#{i18nk}.#{action}")
  end

  # Generates a link like "Create New Option Set" given a klass
  # options[:js] - if true, the link just points to # with expectation that js will bind to it
  def create_link(klass, options = {})
    i18nk = klass.model_name.i18n_key
    href = options[:js] ? "#" : dynamic_path(klass, action: :new)
    link_to(translate_action(klass, :new), href, class: "create_#{klass.model_name.param_key}")
  end

  # Builds links for the action links at the top of a new/edit/show page.
  # If a block is given, appends return value from block to end of div.
  # Block should returns an html_safe string.
  def top_action_links(*args, &block)
    options = args.extract_options!
    options[:except] = Array.wrap(options[:except])
    options[:only] = Array.wrap(options[:only]) unless options[:only].nil?
    options[:append] = Array.wrap(options[:append])

    obj = args.first
    raise ArgumentError, "Missing target object" if obj.nil?

    controller = options[:controller] || obj.class.model_name.plural
    i18nk = obj.class.model_name.i18n_key

    actions_to_show = options[:only] || %i[index new show edit destroy]
    actions_to_show -= %i[new show edit destroy] if canonical_action == :new
    actions_to_show -= options[:except]
    actions_to_show += options[:append]
    actions_to_show.delete(canonical_action)

    content_tag(:div, class: "top-action-links d-print-none") do
      main_links = "".html_safe
      main_links << actions_to_show.map do |action|
        url = begin
                url_for(controller: controller, action: action)
              rescue StandardError
                nil
              end

        next unless url && can?(action, %w[index new].include?(action) ? obj.class : obj)
        link_to(icon_tag(action) + translate_action(obj, action), url,
          method: action == :destroy ? :delete : nil,
          data: {confirm: action == :destroy ? delete_warning(obj) : nil},
          class: "#{action}-link")
      end.compact.reduce(:<<)
      main_links << (block_given? ? capture(&block) : "")
    end
  end

  def delete_warning(obj, options = {})
    description = options[:obj_description] || "#{obj.class.model_name.human} '#{obj.name}'"
    t("layout.delete_warning", obj_description: description)
  end

  # returns the html for an action icon using font awesome and the mappings defined in IconHelper
  def action_link(action, href, options = {})
    options[:class] = Array.wrap(options[:class])
    options[:class] << "action-link" << "action-link-#{action.to_s.dasherize}"
    options[:class] = options[:class].join(" ")

    if options.delete(:label) == false
      link_to(icon_tag(action), href, options)
    else
      label = t("actions.#{action}")
      link_to(icon_tag(action) << label, href, options)
    end
  end

  # creates a link to a batch operation
  def batch_op_link(options)
    link_to(options[:name], "#", data: options.slice(:path, :confirm), class: "batch_op_link")
  end
end
