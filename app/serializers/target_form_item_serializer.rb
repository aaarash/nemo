# frozen_string_literal: true

# Serializes form items for cases where they are targets of conditional logic, like left_qing or dest_item.
class TargetFormItemSerializer < ActiveModel::Serializer
  attributes :id, :code, :rank, :full_dotted_rank
  format_keys :lower_camel
end
