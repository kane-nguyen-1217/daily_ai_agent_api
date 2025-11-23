class CryptoDataService
  # Fetches crypto prices from external API (CoinGecko, CoinMarketCap, etc.)
  
  def self.fetch_price(symbol)
    # This is a placeholder - integrate with actual crypto API
    # Example: CoinGecko API, CoinMarketCap API, etc.
    
    api_url = ENV.fetch('CRYPTO_API_URL', 'https://api.coingecko.com/api/v3')
    api_key = ENV['CRYPTO_API_KEY']
    
    response = HTTParty.get(
      "#{api_url}/simple/price",
      query: {
        ids: symbol_to_id(symbol),
        vs_currencies: 'usd',
        include_market_cap: true,
        include_24hr_vol: true,
        include_24hr_change: true,
        include_last_updated_at: true
      },
      headers: api_key ? { 'X-CMC_PRO_API_KEY' => api_key } : {}
    )
    
    if response.success?
      data = response.parsed_response.values.first
      {
        price: data['usd'],
        market_cap: data['usd_market_cap'],
        volume_24h: data['usd_24h_vol'],
        change_24h: data['usd_24h_change'],
        change_7d: nil, # Would need separate API call
        additional_data: data
      }
    else
      # Return mock data for development
      {
        price: rand(100..50000),
        market_cap: rand(1_000_000_000..1_000_000_000_000),
        volume_24h: rand(1_000_000..100_000_000),
        change_24h: rand(-10.0..10.0).round(2),
        change_7d: rand(-20.0..20.0).round(2),
        additional_data: {}
      }
    end
  rescue => e
    Rails.logger.error("Crypto API error: #{e.message}")
    # Return mock data on error
    {
      price: 0,
      market_cap: 0,
      volume_24h: 0,
      change_24h: 0,
      change_7d: 0,
      additional_data: { error: e.message }
    }
  end
  
  def self.symbol_to_id(symbol)
    # Map common symbols to CoinGecko IDs
    mapping = {
      'BTC' => 'bitcoin',
      'ETH' => 'ethereum',
      'SOL' => 'solana',
      'ADA' => 'cardano',
      'DOT' => 'polkadot'
    }
    mapping[symbol.upcase] || symbol.downcase
  end
end
