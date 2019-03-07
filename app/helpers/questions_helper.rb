# frozen_string_literal: true

module QuestionsHelper
  def questions_index_links(_questions)
    links = []

    # links for form mode
    if params[:controller] == "forms"
      # add the 'add questions to form' link if there are some questions
      unless @questions.empty?
        links << batch_op_link(name: t("form.add_selected"), path: add_questions_form_path(@form))
      end

      # add the create new questions link
      links << create_link(Question, js: true) if can?(:create, Question)

    # otherwise, we're in regular questions mode
    else
      # add the create new question
      links << create_link(Question) if can?(:create, Question)

      links << batch_op_link(
        name: t("question.bulk_destroy"),
        path: bulk_destroy_questions_path,
        confirm: "question.bulk_destroy_confirm"
      )

      add_import_standard_link_if_appropriate(links)
    end

    # return the link set
    links
  end

  def questions_index_fields
    fields = %w[std_icon code name type]
    fields << "published" unless admin_mode?
    fields
  end

  def format_questions_field(question, field)
    case field
    when "std_icon" then std_icon(question)
    when "type" then t(question.qtype_name, scope: :question_type)
    when "published" then tbool(question.published?)
    when "name"
      if params[:controller] == "forms"
        html_escape(question.name_or_none) << render_tags(question.sorted_tags)
      else
        link_to(question.name_or_none, question.default_path) <<
          render_tags(question.sorted_tags, clickable: true)
      end
    else question.send(field)
    end
  end

  # Builds option tags for the given option sets. Adds multilevel data attrib.
  # If no option sets found, returns empty string.
  def option_set_select_option_tags(sets, selected_id)
    sets.map do |s|
      content_tag(:option, s.name, value: s.id, selected: s.id == selected_id ? "selected" : nil,
                                   "data-multilevel": s.multilevel?)
    end.reduce(:<<) || ""
  end

  def maxmin_strictly_label(method)
    t("question.maxmin.strictly_" + (method == :casted_minimum ? "gt" : "lt"))
  end
end
