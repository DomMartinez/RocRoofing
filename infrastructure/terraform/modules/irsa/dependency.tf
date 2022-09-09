resource "null_resource" "dependency_getter" {
  triggers = {
    dependants = "${join(",", var.dependencies)}"
  }
}
