# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: form_items
#
#  id                           :uuid             not null, primary key
#  ancestry                     :text
#  ancestry_depth               :integer          not null
#  default                      :string
#  display_if                   :string           default("always"), not null
#  group_hint_translations      :jsonb
#  group_item_name_translations :jsonb
#  group_name_translations      :jsonb
#  hidden                       :boolean          default(FALSE), not null
#  one_screen                   :boolean
#  rank                         :integer          not null
#  read_only                    :boolean
#  repeatable                   :boolean
#  required                     :boolean          default(FALSE), not null
#  type                         :string(255)      not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  form_id                      :uuid             not null
#  form_old_id                  :integer
#  mission_id                   :uuid
#  old_id                       :integer
#  question_id                  :uuid
#  question_old_id              :integer
#
# Indexes
#
#  index_form_items_on_ancestry                 (ancestry)
#  index_form_items_on_form_id                  (form_id)
#  index_form_items_on_form_id_and_question_id  (form_id,question_id) UNIQUE
#  index_form_items_on_mission_id               (mission_id)
#  index_form_items_on_question_id              (question_id)
#
# Foreign Keys
#
#  form_items_form_id_fkey      (form_id => forms.id) ON DELETE => restrict ON UPDATE => restrict
#  form_items_mission_id_fkey   (mission_id => missions.id) ON DELETE => restrict ON UPDATE => restrict
#  form_items_question_id_fkey  (question_id => questions.id) ON DELETE => restrict ON UPDATE => restrict
#
# rubocop:enable Metrics/LineLength

class QingGroup < FormItem
  include Translatable

  translates :group_name, :group_hint, :group_item_name

  alias_method :c, :sorted_children

  def code
    group_name
  end

  def qtype_name
    nil
  end

  def child_groups
    children.where(type: "QingGroup")
  end

  def group?
    true
  end

  def option_set_id
    nil
  end

  def fragment?
    false
  end

  def multilevel_fragment?
    false
  end

  def preordered_option_nodes
    []
  end

  def normalize
    super
    self.group_item_name_translations = {} unless repeatable?
    true
  end
end
