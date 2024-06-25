class CreateDummyModels < ActiveRecord::Migration[7.1]
  def change
    create_table :dummy_models do |t|

      t.timestamps
    end
  end
end
