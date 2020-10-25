Aws.config.update(
    region: 'us-east-1',
    endpoint: "http://localhost:9000",
    force_path_style: true,
    credentials: Aws::Credentials.new(
        "minio",
        "miniostorage"
    )
)