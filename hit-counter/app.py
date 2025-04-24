from rediscluster import RedisCluster
import time
import os
from flask import Flask
REDIS_CLUSTER=os.environ.get('REDIS_CLUSTER')
REDIS_PASS=os.environ.get('REDIS_PASSWORD')
app = Flask(__name__)
startup_nodes = [{"host": REDIS_CLUSTER, "port": "6379"}]
cache = RedisCluster(startup_nodes=startup_nodes,password=REDIS_PASS, decode_responses=True)


def get_hit_count():
    cache.incr('hits')
    return cache.wait


@app.route('/')
def hit():
    count = get_hit_count()
    return 'I have been hit %i times since deployment.\n' % int(count)


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
