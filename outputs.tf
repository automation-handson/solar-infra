output "eks_vpc_id" {
  value = module.networking.vpc_id
}

output "eks_private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "eks_public_subnet_ids" {
  value = module.networking.public_subnet_ids
}