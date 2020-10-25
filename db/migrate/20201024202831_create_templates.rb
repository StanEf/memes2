class CreateTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :templates do |t|
      t.integer :external_id
      t.string :name
      t.string :url
      t.integer :width
      t.integer :height
      t.integer :box_count
    end

    add_index(:templates, :external_id, unique: true)
    add_index(:templates, :name, unique: true)
    add_index(:templates, :url, unique: true)
  end
end
