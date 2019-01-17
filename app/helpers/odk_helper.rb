# frozen_string_literal: true

module OdkHelper
  # For the given subqing, returns an xpath expression for the itemset tag nodeset attribute.
  # E.g. instance('os16')/root/item or
  #      instance('os16')/root/item[parent_id=/data/q2_1] or
  #      instance('os16')/root/item[parent_id=/data/q2_2]
  def multilevel_option_nodeset_ref(qing, cur_subq, xpath_prefix)
    filter = if cur_subq.first_rank?
               ""
             else
               code = cur_subq.odk_code(options: {previous: true})
               path = [xpath_prefix, code].compact.join("/")
               "[parent_id=#{path}]"
    end
    "instance('#{Odk::CodeMapper.instance.code_for_item(qing.option_set)}')/root/item#{filter}"
  end

  # The general structure for a group is:
  # group tag
  #   label
  #   repeat (if repeatable group)
  #     body
  #
  # The general structure for a fragment is:
  # group tag with field-list
  #   hint
  #   questions
  def odk_group_or_fragment(node, xpath_prefix)
    # No need to render empty groups/fragments
    return "" if node.is_childless?

    xpath = "#{xpath_prefix}/#{node.odk_code}"
    odk_group_or_fragment_wrapper(node, xpath) do
      fragments = Odk::QingGroupPartitioner.new.fragment(node)
      if fragments
        fragments.map { |f| odk_group_or_fragment(f, xpath_prefix) }.reduce(:<<)
      else
        odk_inner_group_tag(node) do
          # We include the hint here.
          # In the case of fragments, this means we include hint each time, which is correct.
          # This covers the case where `node` is a fragment, because fragments should always
          # be shown on one screen since that's what they're for.
          odk_group_item_name(node, xpath) << odk_group_hint(node, xpath) << odk_group_body(node, xpath)
        end
      end
    end
  end

  def odk_group_or_fragment_wrapper(node, xpath, &block)
    if node.fragment?
      # Fragments need no outer wrapper, they will get wrapped by field-list further in.
      capture(&block)
    else
      # Groups should get wrapped in a group tag and include the label.
      # Also a repeat tag if the group is repeatable
      content_tag(:group) do
        tag(:label, ref: "jr:itext('#{node.odk_code}:label')") <<
          conditional_tag(:repeat, node.repeatable?, nodeset: xpath) do
            capture(&block)
          end
      end
    end
  end

  # Sometimes we need a second, inner group tag. There are two possible reasons:
  #
  # 1. It's a repeat group, in which case the item label goes inside the inner group.
  # 2. It's a one_screen group, in which case we need to set appearance="field-list"
  #
  # Note both can be true at once.
  def odk_inner_group_tag(node, &block)
    do_inner_tag = node.one_screen_appropriate? || node.repeatable?
    appearance = node.one_screen_appropriate? ? "field-list" : nil
    conditional_tag(:group, do_inner_tag, appearance: appearance) do
      capture(&block)
    end
  end

  def odk_group_hint(node, xpath)
    if node.no_hint?
      "".html_safe
    else
      content_tag(:input, ref: "#{xpath}/header") do
        tag(:hint, ref: "jr:itext('#{node.odk_code}:hint')")
      end
    end
  end

  def odk_group_item_name(node, _xpath)
    # Group item name should only be present for repeatable qing groups.
    if node.respond_to?(:group_item_name) && node.group_item_name && !node.group_item_name.empty?
      tag(:label, ref: "jr:itext('#{node.odk_code}:itemname')")
    else
      "".html_safe
    end
  end

  def odk_group_body(node, xpath)
    render("forms/odk/group_body", node: node, xpath: xpath)
  end

  # Tests if all items in the group are Questionings with the same type and option set.
  def odk_grid_mode?(group)
    items = group.sorted_children
    return false if items.size <= 1 || !group.one_screen?

    items.all? do |i|
      i.is_a?(Questioning) &&
        i.qtype_name == "select_one" &&
        i.option_set == items[0].option_set &&
        !i.multilevel?
    end
  end

  def empty_qing_group?(subtree)
    subtree.keys.empty?
  end

  def organize_qing_groups(descendants)
    QingGroupOdkPartitioner.new(descendants).fragment
  end
end
