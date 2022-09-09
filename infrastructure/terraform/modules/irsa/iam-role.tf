data "aws_iam_policy_document" "service_account_assume_role_policy" {
  count = length(var.namespaces)

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test  = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespaces[count.index]}:${var.name}"]
    }

    principals {
      identifiers = ["${var.oidc_provider_arn}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "service_account_iam_role" {
  count = length(var.namespaces)

  assume_role_policy = data.aws_iam_policy_document.service_account_assume_role_policy[count.index].json
  name               = "${var.eks_cluster_name}-${var.name}-${var.namespaces[count.index]}-oidc"

  tags = merge(
    tomap({
      "Name": "${var.eks_cluster_name}-${var.name}-${var.namespaces[count.index]}-oidc",
      "association": var.eks_cluster_name,
      "service_account": var.name,
      "namespace": "${var.namespaces[count.index]}",
    }),
    var.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "service_account_role_attachment" {
  count = length(var.namespaces)

  role  = aws_iam_role.service_account_iam_role.*.name[count.index]
  policy_arn = var.access_policy_arn
}
