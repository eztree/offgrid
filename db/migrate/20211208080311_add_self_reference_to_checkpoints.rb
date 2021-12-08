class AddSelfReferenceToCheckpoints < ActiveRecord::Migration[6.1]
  def change
    add_reference :checkpoints, :previous_checkpoint, foreign_key: { to_table: :checkpoints }
  end
end
