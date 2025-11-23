module Api
  module V1
    class CryptoDataController < ApplicationController
      def index
        symbols = params[:symbols]&.split(',') || ['BTC', 'ETH', 'SOL']
        data = symbols.map do |symbol|
          cache = CryptoDataCache.get_or_fetch(symbol)
          crypto_response(cache)
        rescue => e
          { symbol: symbol, error: e.message }
        end
        
        render json: { crypto_data: data }
      end
      
      def show
        symbol = params[:id].upcase
        cache = CryptoDataCache.get_or_fetch(symbol)
        render json: { crypto_data: crypto_response(cache) }
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def current_prices
        symbols = params[:symbols]&.split(',') || ['BTC', 'ETH', 'SOL', 'ADA', 'DOT']
        prices = symbols.map do |symbol|
          cache = CryptoDataCache.get_or_fetch(symbol)
          {
            symbol: cache.symbol,
            price: cache.price,
            change_24h: cache.change_24h,
            cached_at: cache.cached_at
          }
        rescue => e
          { symbol: symbol, error: e.message }
        end
        
        render json: { prices: prices }
      end
      
      def historical
        symbol = params[:symbol].upcase
        days = (params[:days] || 7).to_i
        
        # This would fetch historical data from an external API
        # For now, return a placeholder response
        render json: {
          symbol: symbol,
          days: days,
          message: 'Historical data endpoint - integrate with external crypto API'
        }
      end
      
      private
      
      def crypto_response(cache)
        {
          symbol: cache.symbol,
          price: cache.price,
          market_cap: cache.market_cap,
          volume_24h: cache.volume_24h,
          change_24h: cache.change_24h,
          change_7d: cache.change_7d,
          additional_data: cache.additional_data,
          cached_at: cache.cached_at
        }
      end
    end
  end
end
