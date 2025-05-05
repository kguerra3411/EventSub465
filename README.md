# MediaWiki AWS
Deployment configuration of MediaWiki on AWS using Terraform and ECS.

### To use:
0. Make sure you are authenticated with the aws cli
1. Create required variables in `mediawiki-aws/terraform.tfvars`
2. Run the following to create the resources with Terraform
```sh
terraform init
terraform plan
terraform apply
```
3. Follow the url to your MediaWiki install and follow the setup process, downloading the `LocalSettings.php` file when prompted.
4. Upload the file to the s3 bucket through the aws cli or aws console.
5. Restart your ecs service.
6. Visit the URL again and you will be able to finish installing the wiki if prompted and jump into it.
