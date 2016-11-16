# require 'redis'
#$redis = Redis.new(:host => '127.0.0.1', :port=> 6379)
$redis = Redis::Namespace.new("rbacalendar", :redis => Redis.new)