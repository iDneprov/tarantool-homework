vshard = require('vshard')

local topology = require('topology')
local schema = require('schema')

vshard.storage.cfg(
        {
            bucket_count = topology.bucket_count,
            sharding     = topology.sharding,

            memtx_dir  = "replicaset2",
            wal_dir    = "replicaset2",
            replication_connect_quorum = 1,
        },
        'bbbbbbbb-0000-4000-a000-000000000021'
)

schema.init()

require 'console'.start() os.exit()