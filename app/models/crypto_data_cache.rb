# == Schema Information
# Schema version: 20251125143906
#
# Table name: crypto_data_caches
#
#  id              :bigint           not null, primary key
#  additional_data :json
#  cached_at       :datetime
#  change_24h      :decimal(10, 2)
#  change_7d       :decimal(10, 2)
#  market_cap      :decimal(20, 2)
#  price           :decimal(20, 8)
#  symbol          :string           not null
#  volume_24h      :decimal(20, 2)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_crypto_data_caches_on_cached_at  (cached_at)
#  index_crypto_data_caches_on_symbol     (symbol) UNIQUE
#
class CryptoDataCache < ApplicationRecord
  CACHE_DURATION = 5.minutes
  
  validates :symbol, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  scope :fresh, -> { where('cached_at > ?', CACHE_DURATION.ago) }
  scope :stale, -> { where('cached_at <= ?', CACHE_DURATION.ago) }
  
  def self.get_or_fetch(symbol)
    cache = find_by(symbol: symbol.upcase)
    
    if cache&.fresh?
      cache
    else
      fetch_and_cache(symbol)
    end
  end
  
  def self.fetch_and_cache(symbol)
    # Fetch from external API (CoinGecko, CoinMarketCap, etc.)
    data = CryptoDataService.fetch_price(symbol)
    
    cache = find_or_initialize_by(symbol: symbol.upcase)
    cache.update!(
      price: data[:price],
      market_cap: data[:market_cap],
      volume_24h: data[:volume_24h],
      change_24h: data[:change_24h],
      change_7d: data[:change_7d],
      additional_data: data[:additional_data],
      cached_at: Time.current
    )
    
    cache
  end
  
  def fresh?
    cached_at && cached_at > CACHE_DURATION.ago
  end
  
  def stale?
    !fresh?
  end
end
