# ---- network/outputs.tf ----
output "vpc_id" {
  value = aws_vpc.atul_vpc.id
}