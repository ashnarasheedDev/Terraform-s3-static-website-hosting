##------To fetch zone details------##

data "aws_route53_zone" "myzone" {
  name         = "ashna.online"
  private_zone = false
}

##--------To create policy----------##
 
data "aws_iam_policy_document" "bucket_policy" {

  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::webserver.ashna.online"
    ]

  }
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::webserver.ashna.online/*"
    ]
  }
}

##-------To fecth Bucket details-------##

data "aws_s3_bucket" "bucket_url" {
  bucket = aws_s3_bucket.my_bucket.id
}
