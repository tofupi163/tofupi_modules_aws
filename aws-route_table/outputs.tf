output "route_table_id" { 
    value = aws_route_table.this.id 
    description = "route_table_id"
}

output "aws_main_route_table_association_id" {
    value = aws_main_route_table_association.this.id
    description = "aws_main_route_table_association_id"
}

output "aws_route_table_association_id" {
    value = aws_route_table_association.this.id
    description = "aws_route_table_association_id"
}
