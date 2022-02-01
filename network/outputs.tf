output "vpc_id" {
  value = aws_vpc.atul_vpc.id
}
output "public_sg" {
  value = aws_security_group.atul_sg["public"].id
}
output "private_sg" {
  value = aws_security_group.atul_sg["private"].id
}
output "public_subnets" {
  value = aws_subnet.atul_public_subnet.*.id
}
output "private_subnets" {
  value = aws_subnet.atul_private_subnet.*.id
}
output "db_security_group" {
  value = [aws_security_group.atul_sg["rds"].id]
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.atul_rds_subnetgroup.*.name
}
