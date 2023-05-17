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

> creating bucket

The bucket name and website name should be same. The website block is used to configure the bucket for website hosting. In this case, the  index_document attribute is set to "index.html", which specifies that the "index.html" file should be served as the default document for the website

```
resource "aws_s3_bucket" "my_bucket" {
  bucket = "webserver.ashna.online"
  website {
    index_document = "index.html"
   }
}
```
> Creating Locals to map file extensions with their corresponding MIME types

In this code, the mime_types variable is a map that associates file extensions (e.g., "css", "html", "js") with their corresponding MIME types (e.g., "text/css", "text/html", "application/javascript"). The file extensions are used later to determine the content type of each uploaded file.

```
locals {
  mime_types = {
    "css"  = "text/css"
    "html" = "text/html"
    "ico"  = "image/vnd.microsoft.icon"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/json"
    "png"  = "image/png"
    "svg"  = "image/svg+xml"
    "txt"  = "text/plain"
    "jpg"  = "image/jpeg"
    "ttf"  = "application/font"
    "woff" = "application/font"
    "woff2" = "application/octet-stream"
    "eot" = "application/octet-stream"
  }
}
```
> Uploading website contents to s3 from my local machine

The objects are uploaded based on the files present in the local directory "/home/ec2-user/website.

The for_each attribute uses the fileset function to iterate over each file in the "/home/ec2-user/website" directory matching the pattern  The objects are uploaded based on the files present in the local directory "/home/ec2-user/website.

The for_each attribute uses the fileset function to iterate over each file in the "/home/ec2-user/website" directory matching the pattern "**/.". This pattern matches all files with an extension.

	key: The key of the S3 object. It is set to the relative path of the file within the "/home/ec2-user/website" directory.

	source: The local path of the file to be uploaded.

	content_type: The MIME type of the file, determined using the lookup function. It looks up the MIME type from the local.mime_types map based on the file extension.

By executing this Terraform configuration, the files in the "/home/ec2-user/website" directory will be uploaded to the specified S3 bucket with their respective keys and content types.

```
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.my_bucket.bucket 
  for_each = fileset("/home/ec2-user/website", "**/*.*") 
  key          = each.key
  source       = "/home/ec2-user/website/${each.key}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
```

> Allowing public_access to the bucket

All the block_public_* attributes are set to false, allowing public access to the bucket and its objects.

```
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.my_bucket.id
 
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```

> Created a Route 53 record for the specified S3 bucket

The records attribute specifies the value(s) of the record. In this case, it references the website endpoint URL of the S3 bucket, obtained from the data.aws_s3_bucket.bucket_url.website_endpoint data source

```
resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.myzone.zone_id
  name    = "webserver"
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_s3_bucket.bucket_url.website_endpoint]
}
```
## Conclusion

Overall, what I have done is automated the creation of an S3 bucket, uploaded files to it, set a bucket policy, configured public access settings, and created a Route 53 DNS record for the website.

**Note:** Please ensure that you have the necessary variables and data sources defined and that the Route 53 zone and S3 bucket exist with the appropriate configurations before using this code.

