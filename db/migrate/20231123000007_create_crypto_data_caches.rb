class CreateCryptoDataCaches < ActiveRecord::Migration[7.0]
  def change
    create_table :crypto_data_caches do |t|
      t.string :symbol, null: false
      t.decimal :price, precision: 20, scale: 8
      t.decimal :market_cap, precision: 20, scale: 2
      t.decimal :volume_24h, precision: 20, scale: 2
      t.decimal :change_24h, precision: 10, scale: 2
      t.decimal :change_7d, precision: 10, scale: 2
      t.json :additional_data
      t.datetime :cached_at
      
      t.timestamps
    end
    
    add_index :crypto_data_caches, :symbol, unique: true
    add_index :crypto_data_caches, :cached_at
  end
end
