# How to host Static Website on Amazon S3 through Terraform

Amazon Simple Storage Service (Amazon S3) can be used to host static Websites without a need for a Web server (at an extremely low cost). S3 buckets can be used to host the HTML, CSS and JavaScript files for entire static websites


## Advantages of Hosting Website on S3

Here are some of the advantages of hosting site on S3

* **Performance**: The website will be highly performant and scalable at a fraction of the cost of a traditional Web server.

* **Scalability**: Amazon S3 is inherently scalable. For popular websites, the Amazon S3 architecture will scale seamlessly to serve thousands of HTTP requests per second without any changes to the architecture.

* **Availability**: In addition, by hosting with Amazon S3, the website is inherently highly available.

## Features

* Fully automated

**Let’s get in to the code:**

**Created Datasources.tf**

Fetches information about the Route 53 DNS zone named "ashna.online" and stores it in the aws_route53_zone.myzone data object. This can be used later to create DNS records or retrieve zone properties

```
data "aws_route53_zone" "myzone" {
  name         = "ashna.online"
  private_zone = false
}
```
Later I created a policy document. This block creates an IAM policy document that allows these actions on S3 bucket. Once you have this policy document, you can associate it with an IAM policy resource or an S3 bucket resource in your Terraform configuration to grant the specified permissions

```
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::webserver.ashna.online",
      "arn:aws:s3:::webserver.ashna.online/*"
    ]
  }
}
```
**Resource code definition**

> creating bucket. Bucket name must be same as website name you are going to set up.

```
resource "aws_s3_bucket" "my_bucket" {
  bucket = "webserver.ashna.online"
  website {
    index_document = "index.html"
   }
}
```
