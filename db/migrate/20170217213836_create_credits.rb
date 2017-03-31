class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.datetime :fecha
      t.string :code
      t.integer :nota_id
      t.string :motivo
      t.float :subtotal
      t.float :tax
      t.float :total
      t.integer :moneda_id
      t.string :mod_factura
      t.integer :mod_tipo

      t.timestamps null: false
    end
  end
end
