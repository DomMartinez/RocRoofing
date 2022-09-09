resource "kubernetes_service_account" "service_account" {
  count = var.create_service_account ? length(var.namespaces) : 0

  metadata {
    name = var.name
    namespace = var.namespaces[count.index]

    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.service_account_iam_role[count.index].arn}"
    }
  }

  depends_on = [
    null_resource.dependency_getter
  ]
}
