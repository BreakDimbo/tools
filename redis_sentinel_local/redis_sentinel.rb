#!/Users/break/.rvm/rubies/ruby-2.4.2/bin/ruby

RedisConfRootPath = "~/Documents/geek/redis_sentinel"

def start_sentinel_cluster
  start_redis
  start_sentinel
end

def start_redis
  config_paths = []
  config_paths << redis_conf_master_path = "#{RedisConfRootPath}/redis.conf"
  config_paths << redis_conf_slave1_path = "#{RedisConfRootPath}/redis-slave1.conf"
  config_paths << redis_conf_slave2_path = "#{RedisConfRootPath}/redis-slave2.conf"

  config_paths.each {|path| `redis-server #{path}`}
end

def start_sentinel
  config_paths = []
  config_paths << redis_conf_master_path = "#{RedisConfRootPath}/redis-sentinel.conf"
  config_paths << redis_conf_slave1_path = "#{RedisConfRootPath}/redis-sentinel1.conf"
  config_paths << redis_conf_slave2_path = "#{RedisConfRootPath}/redis-sentinel2.conf"

  config_paths.each {|path| `redis-server #{path} --sentinel`}
end

def stop_sentinel_cluster
  stop_all
end

def stop_all
  ports = []
  ports << "7790"
  ports << "7791"
  ports << "7792"
  ports << "26370"
  ports << "26371"
  ports << "26372"

  password = "ORjPtnqVDlrlnkP5KoT5"
  ports.each {|port| `redis-cli -p #{port} -a #{password} shutdown`}
end

def parse_input
  input = ARGV[0]
  case input
  when "on"
    start_sentinel_cluster
  when "off"
    stop_sentinel_cluster
  else
    puts "wrong param #{input}, should be on or off"
  end
end

parse_input