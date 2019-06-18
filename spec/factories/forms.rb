# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: forms
#
#  id                    :uuid             not null, primary key
#  access_level          :string(255)      default("private"), not null
#  allow_incomplete      :boolean          default(FALSE), not null
#  authenticate_sms      :boolean          default(TRUE), not null
#  default_response_name :string
#  downloads             :integer
#  name                  :string(255)      not null
#  pub_changed_at        :datetime
#  published             :boolean          default(FALSE), not null
#  sms_relay             :boolean          default(FALSE), not null
#  smsable               :boolean          default(FALSE), not null
#  standard_copy         :boolean          default(FALSE), not null
#  upgrade_needed        :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  current_version_id    :uuid
#  mission_id            :uuid
#  original_id           :uuid
#  root_id               :uuid
#
# Indexes
#
#  index_forms_on_current_version_id  (current_version_id)
#  index_forms_on_mission_id          (mission_id)
#  index_forms_on_original_id         (original_id)
#  index_forms_on_root_id             (root_id) UNIQUE
#
# Foreign Keys
#
#  forms_current_version_id_fkey  (current_version_id => form_versions.id) ON DELETE => nullify ON UPDATE => restrict
#  forms_mission_id_fkey          (mission_id => missions.id) ON DELETE => restrict ON UPDATE => restrict
#  forms_original_id_fkey         (original_id => forms.id) ON DELETE => nullify ON UPDATE => restrict
#  forms_root_id_fkey             (root_id => form_items.id) ON DELETE => restrict ON UPDATE => restrict
#
# rubocop:enable Metrics/LineLength

# TODO: Should be a way to refactor this to be part of the questioning factory.
def create_questioning(qtype_name_or_question, form, attribs = {})
  attribs[:parent] ||= form.root_group
  evaluator = attribs.delete(:evaluator)

  question = if qtype_name_or_question.is_a?(Question)
               qtype_name_or_question
             else
               pseudo_qtype_name = qtype_name_or_question

               q_attribs = {
                 mission: form.mission,
                 use_geo_option_set: pseudo_qtype_name.match?(/geo/),
                 multilingual: pseudo_qtype_name.match?(/multilingual/),
                 with_user_locale: pseudo_qtype_name.match?(/with_user_locale/),
                 auto_increment: pseudo_qtype_name == "counter_with_inc",
                 metadata_type: %w[formstart formend].include?(pseudo_qtype_name) ? pseudo_qtype_name : nil
               }

               if evaluator.try(:option_set)
                 q_attribs[:option_set] = evaluator.option_set
               elsif evaluator.try(:option_names)
                 q_attribs[:option_names] = evaluator.option_names
               end

               q_attribs[:qtype_name] =
                 case pseudo_qtype_name
                 when "select_one_as_text_for_sms", "select_one_with_appendix_for_sms", "geo_select_one",
                   "multilevel_select_one", "geo_multilevel_select_one", "large_select_one",
                   "super_multilevel_select_one", "multilevel_select_one_as_text_for_sms"
                   "select_one"
                 when "select_multiple_with_appendix_for_sms", "large_select_multiple"
                   "select_multiple"
                 when "multilingual_text", "multilingual_text_with_user_locale"
                   "text"
                 when "counter_with_inc"
                   "counter"
                 when "formstart", "formend"
                   "datetime"
                 else
                   pseudo_qtype_name
                 end

               preset_opt_sets_qtypes = %w[geo_select_one multilevel_select_one geo_multilevel_select_one
                                           large_select_one super_multilevel_select_one
                                           multilevel_select_one_as_text_for_sms large_select_multiple]
               if preset_opt_sets_qtypes.include?(pseudo_qtype_name)
                 q_attribs[:option_names] = pseudo_qtype_name.match(/(.+)_select_/)[1].to_sym
               end

               question = build(:question, q_attribs)
               question.option_set.sms_guide_formatting = "treat_as_text" if pseudo_qtype_name.match?(/as_text_for_sms/)
               question.option_set.sms_guide_formatting = "appendix" if pseudo_qtype_name.match?(/with_appendix_for_sms/)
               question
  end

  attribs[:mission] = form.mission
  attribs[:form] = form
  attribs[:question] = question
  create(:questioning, attribs)
end

def build_item(item, form, parent, evaluator)
  if item.is_a?(Hash) && item.key?(:repeating)
    item = item[:repeating]
    item = {items: item} if item.is_a?(Array)
    group = create(:qing_group,
      parent: parent,
      form: form,
      group_name_en: item[:name],
      group_hint_en: item[:name],
      group_item_name: item[:item_name],
      repeatable: true)
    item[:items].each { |c| build_item(c, form, group, evaluator) }
  elsif item.is_a?(Array)
    group = create(:qing_group,
      parent: parent,
      form: form,
      group_name_en: "Group Name",
      group_hint_en: "Group Hint")
    item.each { |q| build_item(q, form, group, evaluator) }
  else # must be a questioning
    create_questioning(item, form, parent: parent, evaluator: evaluator)
  end
end

# Only works with create
FactoryGirl.define do
  factory :form do
    transient do
      # Can specify questions or question_types. questions takes precedence.
      questions []
      question_types []

      # Args to forward to question factory.
      option_set nil
      option_names nil
    end

    authenticate_sms false
    mission { get_mission }
    sequence(:name) { |n| "Sample Form #{n}" }

    after(:create) do |form, evaluator|
      items = evaluator.questions.presence || evaluator.question_types
      # Build questions.
      items.each do |item|
        build_item(item, form, form.root_group, evaluator)
      end
    end

    trait :standard do
      mission { nil }
    end

    trait :with_version do
      transient { version nil }

      after(:create) do |form, evaluator|
        cv = form.current_version
        cv.update(code: evaluator.version) if cv && evaluator.version
      end
    end

    trait :published do
      after(:create, &:publish!)
    end

    # DO NOT USE, USE FORM ABOVE
    # A form with different question types.
    # We hardcode names to make expectations easier, since we assume no more than one sample form per test.
    # Used in the feature specs
    factory :sample_form do
      name "Sample Form"

      after(:create) do |form, _evaluator|
        form.questionings do
          [
            # Single level select_one question.
            create(:questioning, mission: mission, form: form, parent: form.root_group,
                                 question: create(:question, mission: mission, name: "Question 1", hint: "Hint 1",
                                                             qtype_name: "select_one", option_set: create(:option_set, name: "Set 1"))),

            # Multilevel select_one question.
            create(:questioning, mission: mission, form: form, parent: form.root_group,
                                 question: create(:question, mission: mission, name: "Question 2", hint: "Hint 2",
                                                             qtype_name: "select_one", option_set: create(:option_set, name: "Set 2", option_names: :multilevel))),

            # Integer question.
            create(:questioning, mission: mission, form: form, parent: form.root_group,
                                 question: create(:question, mission: mission, name: "Question 3", hint: "Hint 3",
                                                             qtype_name: "integer"))
          ]
        end
      end
    end
  end
end
