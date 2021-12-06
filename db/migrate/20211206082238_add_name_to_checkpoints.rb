class AddNameToCheckpoints < ActiveRecord::Migration[6.1]
  def change
    add_column :checkpoints, :name, :string
  end
end
