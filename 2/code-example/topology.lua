return {
    bucket_count = 16,
    sharding = {
        ['aaaaaaaa-0000-4000-a000-000000000000'] = {
            replicas = {
                ['aaaaaaaa-0000-4000-a000-000000000011'] = {
                    name = 'replicaset1',
                    master=true,
                    uri="sharding:pass@127.0.0.1:30011"
                },
            }
        },
        ['bbbbbbbb-0000-4000-a000-000000000000'] = {
            replicas = {
                ['bbbbbbbb-0000-4000-a000-000000000021'] = {
                    name='replicaset2',
                    master=true,
                    uri="sharding:pass@127.0.0.1:30021"
                },
            },
            weight = 0,
        },
    }
}