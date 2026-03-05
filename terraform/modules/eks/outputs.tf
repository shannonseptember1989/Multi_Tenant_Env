output "cluster_name"           { value = aws_eks_cluster.main.name }
output "cluster_endpoint"       { value = aws_eks_cluster.main.endpoint }
output "cluster_ca_certificate" { value = aws_eks_cluster.main.certificate_authority[0].data  sensitive = true }
output "cluster_version"        { value = aws_eks_cluster.main.version }
output "node_group_arn"         { value = aws_eks_node_group.main.arn }
output "node_security_group_id" { value = aws_security_group.eks_nodes.id }
output "ecr_repository_url"     { value = aws_ecr_repository.wordpress.repository_url }
output "ecr_repository_name"    { value = aws_ecr_repository.wordpress.name }
