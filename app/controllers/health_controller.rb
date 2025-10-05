class HealthController < ApplicationController
  # Skip authentication for health checks
  skip_before_action :authenticate_user!
  skip_before_action :check_authorization

  def show
    checks = {
      status: "ok",
      timestamp: Time.current.iso8601,
      version: Rails.application.config.version,
      environment: Rails.env,
      database: database_check,
      redis: redis_check,
      memory: memory_check
    }

    if checks[:database] == "ok" && checks[:redis] == "ok"
      render json: checks, status: :ok
    else
      render json: checks, status: :service_unavailable
    end
  end

  private

  def database_check
    ActiveRecord::Base.connection.execute("SELECT 1")
    "ok"
  rescue => e
    Rails.logger.error "Database health check failed: #{e.message}"
    "error"
  end

  def redis_check
    # Only check Redis if it's configured
    if defined?(Redis) && Rails.application.config.cache_store.first == :redis_cache_store
      Redis.new(url: Rails.application.config.cache_store.last[:url]).ping
      "ok"
    else
      "not_configured"
    end
  rescue => e
    Rails.logger.error "Redis health check failed: #{e.message}"
    "error"
  end

  def memory_check
    # Get memory usage in MB
    if File.exist?("/proc/meminfo")
      meminfo = File.read("/proc/meminfo")
      total_match = meminfo.match(/MemTotal:\s+(\d+)\s+kB/)
      available_match = meminfo.match(/MemAvailable:\s+(\d+)\s+kB/)

      if total_match && available_match
        total = total_match[1].to_i / 1024
        available = available_match[1].to_i / 1024
        used = total - available
        usage_percent = (used.to_f / total * 100).round(2)

        {
          total_mb: total,
          used_mb: used,
          available_mb: available,
          usage_percent: usage_percent
        }
      else
        "unavailable"
      end
    else
      "unavailable"
    end
  rescue => e
    Rails.logger.error "Memory health check failed: #{e.message}"
    "error"
  end
end
