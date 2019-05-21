# frozen_string_literal: true

# Models a restriction on valid answers, similar to a Rails validation, but for NEMO forms.
class Constraint < ApplicationRecord
  include FormLogical
  include Translatable

  translates :rejection_msg

  validates :conditions, presence: true

  replicable child_assocs: [:conditions], dont_copy: %i[source_item_id],
             backward_assocs: [:source_item]
end
