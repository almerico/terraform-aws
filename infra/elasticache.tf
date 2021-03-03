resource "aws_security_group" "redis" {

  vpc_id = data.aws_vpc.eks_vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_elasticache_subnet_group" "cache" {
  name       = "tf-iterrate-cache-subnet"
  subnet_ids = aws_subnet.eks_subnet[*].id
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "cluster-iterate"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  security_group_ids   = [aws_security_group.redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.cache.id
}
output "elasticache_address" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}
