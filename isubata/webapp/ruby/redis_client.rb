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

    def get_last_message_ids(user_id, channel_ids)
      @@redis.mget(*(channel_ids.map {|id| key_last_message_id(user_id, id)}))
    end

    def set_last_message_id(user_id, channel_id, last_message_id)
      @@redis.set(key_last_message_id(user_id, channel_id), last_message_id)
    end

    def incr_message_cnt(channel_id)
      @@redis.incr(key_message_cnt(channel_id))
    end

    def initialize_message_cnt(rows)
      reset_message_cnt
      key_pairs = rows.map {|row| [key_message_cnt(row['channel_id']), row['cnt']]}
      @@redis.mset(*(key_pairs.flatten))
    end

    def reset_message_cnt
      keys = @@redis.keys("isu:message_cnt:*")
      return if keys.empty?
      @@redis.del(*keys)
    end

    def get_message_cnt(channel_id)
      @@redis.get(key_message_cnt(channel_id)).to_i
    end

    private

    def key_last_message_id(user_id, channel_id)
      "isu:last_message_id:#{user_id}:#{channel_id}"
    end

    def key_message_cnt(channel_id)
      "isu:message_cnt:#{channel_id}"
    end

  end
end
