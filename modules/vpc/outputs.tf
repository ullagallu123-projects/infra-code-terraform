output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for public in aws_subnet.public : public.id]
}

output "private_subnet_ids" {
  value = [for private in aws_subnet.private : private.id]
}

output "db_subnet_ids" {
  value = [for database in aws_subnet.database : database.id]
}

output "db_subnet_group" {
  value = aws_db_subnet_group.main.name
}