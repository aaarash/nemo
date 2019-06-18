# frozen_string_literal: true

class AddKeys < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key "answers", "options", name: "answers_option_id_fk"
    add_foreign_key "answers", "questionings", name: "answers_questioning_id_fk"
    add_foreign_key "answers", "responses", name: "answers_response_id_fk"
    add_foreign_key "assignments", "missions", name: "assignments_mission_id_fk"
    add_foreign_key "assignments", "users", name: "assignments_user_id_fk"
    add_foreign_key "broadcast_addressings", "broadcasts", name: "broadcast_addressings_broadcast_id_fk"
    add_foreign_key "broadcast_addressings", "users", name: "broadcast_addressings_user_id_fk"
    add_foreign_key "broadcasts", "missions", name: "broadcasts_mission_id_fk"
    add_foreign_key "choices", "answers", name: "choices_answer_id_fk"
    add_foreign_key "choices", "options", name: "choices_option_id_fk"
    add_foreign_key "conditions", "options", name: "conditions_option_id_fk"
    add_foreign_key "conditions", "questionings", name: "conditions_questioning_id_fk"
    add_foreign_key "conditions", "questionings", name: "conditions_ref_qing_id_fk", column: "ref_qing_id"
    add_foreign_key "form_versions", "forms", name: "form_versions_form_id_fk"
    add_foreign_key "forms", "form_versions", name: "forms_current_version_id_fk", column: "current_version_id"
    add_foreign_key "forms", "missions", name: "forms_mission_id_fk"
    add_foreign_key "option_sets", "missions", name: "option_sets_mission_id_fk"
    add_foreign_key "optionings", "options", name: "optionings_option_id_fk"
    add_foreign_key "optionings", "option_sets", name: "optionings_option_set_id_fk"
    add_foreign_key "options", "missions", name: "options_mission_id_fk"
    add_foreign_key "questionings", "forms", name: "questionings_form_id_fk"
    add_foreign_key "questionings", "questions", name: "questionings_question_id_fk"
    add_foreign_key "questions", "missions", name: "questions_mission_id_fk"
    add_foreign_key "questions", "option_sets", name: "questions_option_set_id_fk"
    add_foreign_key "report_calculations", "questions", name: "report_calculations_question1_id_fk", column: "question1_id"
    add_foreign_key "report_calculations", "report_reports", name: "report_calculations_report_report_id_fk"
    add_foreign_key "report_option_set_choices", "option_sets", name: "report_option_set_choices_option_set_id_fk"
    add_foreign_key "report_option_set_choices", "report_reports", name: "report_option_set_choices_report_report_id_fk"
    add_foreign_key "report_reports", "search_searches", name: "report_reports_filter_id_fk", column: "filter_id"
    add_foreign_key "report_reports", "missions", name: "report_reports_mission_id_fk"
    add_foreign_key "responses", "forms", name: "responses_form_id_fk"
    add_foreign_key "responses", "missions", name: "responses_mission_id_fk"
    add_foreign_key "responses", "users", name: "responses_user_id_fk"
    add_foreign_key "settings", "missions", name: "settings_mission_id_fk"
    add_foreign_key "sms_messages", "missions", name: "sms_messages_mission_id_fk"
    add_foreign_key "users", "missions", name: "users_current_mission_id_fk", column: "current_mission_id"
  end
end
