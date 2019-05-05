require 'redis'
require 'redis/connection/hiredis'

class RedisClient
  @@redis = (Thread.current[:isu_redis] ||= Redis.new(host: (ENV["REDIS_HOST"] || "13.230.223.121"), port: 6379))
  class << self
  end
end
