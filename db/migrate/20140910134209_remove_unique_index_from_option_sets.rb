# frozen_string_literal: true

class RemoveUniqueIndexFromOptionSets < ActiveRecord::Migration[4.2]
  def up
    remove_index "option_sets", %w[mission_id name]
  end

  def down
  end
end
