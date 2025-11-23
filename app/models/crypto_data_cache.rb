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
