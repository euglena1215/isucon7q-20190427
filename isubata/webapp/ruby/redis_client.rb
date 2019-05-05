require 'redis'
require 'redis/connection/hiredis'

class RedisClient
  @@redis = (Thread.current[:isu_redis] ||= Redis.new(host: (ENV["REDIS_HOST"] || "127.0.0.1"), port: 6379))
  class << self

    def reset_last_message_id
      keys = @@redis.keys("isu:last_message_id:*")
      return if keys.empty?
      @@redis.del(*keys)
    end

    def get_last_message_id(user_id, channel_id)
      @@redis.get(key_last_message_id(user_id, channel_id))
    end

    def set_last_message_id(user_id, channel_id, last_message_id)
      @@redis.set(key_last_message_id(user_id, channel_id), last_message_id)
    end

    private

    def key_last_message_id(user_id, channel_id)
      "isu:last_message_id:#{user_id}:#{channel_id}"
    end
  end
end
