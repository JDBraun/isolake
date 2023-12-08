### Overview
- Isolake is an isolated Databricks environment with scoped-down policies, no non-Databricks or non-AWS outbound connectivity, enterprise security Databricks features (e.g. PrivateLink, CMK, audit logs etc.),and optionally only accessible through an AWS AppStream instance.

-----------
### Disclaimer
This Terraform code is provided as a sample for reference and testing purposes only. Please review and modify the code according to your needs before using it in your test environment.

**NOTE:** The practice of passing credentials through Terraform input variables is intended solely for rapid testing purposes. 
- It should NOT be implemented in production ennvironment or any other higher-level environments.
- For enhanced security, it is recommended to use more secure methods like AWS Secret Manager or environment-specific secrets for storing credentials.
-----------
### Architecture
![Isolake Architecture](https://github.com/JDBraun/isolake/blob/origin/img/isolake-network-topology.png)

-----------
### Version Requirements

| Name | Version |
|------|---------|
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | 1.27.0 |

### Inputs - Main "Isolake" Module

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS account ID for integration | `string` | n/a | yes |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Databricks client ID for OAuth | `string` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | Databricks client secret for OAuth | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for resource deployment | `string` | n/a | yes |
| <a name="input_resource_owner"></a> [resource\_owner](#input\_resource\_owner) | Owner of the resources for tracking and management | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for naming created resources | `string` | n/a | yes |



### Sub Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_audit"></a> [audit](#module\_audit) | ./audit | n/a |
| <a name="module_databricks_cluster"></a> [databricks\_cluster](#module\_databricks\_cluster) | ./cluster | n/a |
| <a name="module_databricks_mws_workspace"></a> [databricks\_mws\_workspace](#module\_databricks\_mws\_workspace) | ./workspace | n/a |
| <a name="module_lockdown_access"></a> [lockdown\_access](#module\_lockdown\_access) | ./lockdown/access | n/a |
| <a name="module_lockdown_data_bucket"></a> [lockdown\_data\_bucket](#module\_lockdown\_data\_bucket) | ./lockdown/data_bucket | n/a |
| <a name="module_lockdown_dbfs"></a> [lockdown\_dbfs](#module\_lockdown\_dbfs) | ./lockdown/dbfs | n/a |
| <a name="module_lockdown_nacls"></a> [lockdown\_nacls](#module\_lockdown\_nacls) | ./lockdown/nacls | n/a |
| <a name="module_uc_data"></a> [uc\_data](#module\_uc\_data) | ./uc_data | n/a |
| <a name="module_uc_init"></a> [uc\_init](#module\_uc\_init) | ./uc_init | n/a |
| <a name="module_uc_assignment"></a> [uc\_init](#module\_uc\_assignment) | ./uc_assignment | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.1.1 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 3.11.0 |


## Inputs - Sub Modules

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS account ID for integration | `string` | n/a | yes |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Databricks client ID for OAuth | `string` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | Databricks client secret for OAuth | `string` | n/a | yes |
| <a name="input_control_plane_ip"></a> [control\_plane\_ip](#input\_control\_plane\_ip) | IP for Databricks control plane | `string` | n/a | yes |
| <a name="input_data_access"></a> [data\_access](#input\_data\_access) | Name of the user or entity that will be given read access to the data in UC | `string` | n/a | yes |
| <a name="input_data_bucket"></a> [data\_bucket](#input\_data\_bucket) | Name of the existing data bucket | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID | `string` | n/a | yes |
| <a name="input_dbfsname"></a> [dbfsname](#input\_dbfsname) | S3 bucket name for the workspace root storage | `string` | n/a | yes |
| <a name="input_enable_cluster_example"></a> [enable\_cluster\_example](#input\_enable\_cluster\_example) | Flag to enable example cluster with Derby Metastore | `bool` | n/a | yes |
| <a name="input_enable_dbfs_lockdown"></a> [enable\_dbfs\_lockdown](#input\_enable\_dbfs\_lockdown) | Lockdown on workspace root bucket | `bool` | n/a | yes |
| <a name="input_enable_front_end_lockdown"></a> [enable\_front\_end\_lockdown](#input\_enable\_front\_end\_lockdown) | Flag to enable frontend lockdown | `bool` | n/a | yes |
| <a name="input_enable_nacl_lockdown"></a> [enable\_nacl\_lockdown](#input\_enable\_nacl\_lockdown) | Lockdown on private subnet NACLs | `bool` | n/a | yes |
| <a name="input_enable_read_only_data_bucket_lockdown"></a> [enable\_read\_only\_data\_bucket\_lockdown](#input\_enable\_read\_only\_data\_bucket\_lockdown) | Read-only lockdown on data bucket | `bool` | n/a | yes |
| <a name="input_full_region_name"></a> [full\_region\_name](#input\_full\_region\_name) | Full name of the region for restrictive DBFS bucket policies | `string` | n/a | yes |
| <a name="input_private_subnets_cidr"></a> [private\_subnets\_cidr](#input\_private\_subnets\_cidr) | CIDR blocks for private subnets | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for resource deployment | `string` | n/a | yes |
| <a name="input_region_name"></a> [region\_name](#input\_region\_name) | Short name of the region | `string` | n/a | yes |
| <a name="input_relay_vpce_service"></a> [relay\_vpce\_service](#input\_relay\_vpce\_service) | VPCE service for relay | `string` | n/a | yes |
| <a name="input_resource_owner"></a> [resource\_owner](#input\_resource\_owner) | Owner of the resources for tracking and management | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for naming created resources | `string` | n/a | yes |
| <a name="input_restricted_uc_bucket_policy"></a> [restricted\_uc\_bucket\_policy](#input\_restricted\_uc\_bucket\_policy) | Restrictive policy on Unity Catalog bucket | `bool` | n/a | yes |
| <a name="input_sg_egress_protocol"></a> [sg\_egress\_protocol](#input\_sg\_egress\_protocol) | Allowed protocols for within security group egress | `list(string)` | n/a | yes |
| <a name="input_sg_ingress_protocol"></a> [sg\_ingress\_protocol](#input\_sg\_ingress\_protocol) | Allowed protocols for within security group ingress | `list(string)` | n/a | yes |
| <a name="input_system_arn"></a> [system\_arn](#input\_system\_arn) | System ARN for bucket policies | `string` | n/a | yes |
| <a name="input_system_ip"></a> [system\_ip](#input\_system\_ip) | System IP for administrative access and bucket policies | `string` | n/a | yes |
| <a name="input_ucname"></a> [ucname](#input\_ucname) | S3 bucket name for the Unity Catalog (UC) metastore | `string` | n/a | yes |
| <a name="input_vpc_cidr_range"></a> [vpc\_cidr\_range](#input\_vpc\_cidr\_range) | CIDR range for the VPC | `string` | n/a | yes |
| <a name="input_workspace_vpce_service"></a> [workspace\_vpce\_service](#input\_workspace\_vpce\_service) | VPCE service for workspace | `string` | n/a | yes |
| <a name="input_ws_ld_availability_zones"></a> [ws\_ld\_availability\_zones](#input\_ws\_ld\_availability\_zones) | Availability zone for AppStream | `list(string)` | n/a | yes |
| <a name="input_ws_ld_private_subnets_cidr"></a> [ws\_ld\_private\_subnets\_cidr](#input\_ws\_ld\_private\_subnets\_cidr) | CIDR for AppStream private subnets | `list(string)` | n/a | yes |
| <a name="input_ws_ld_vpc_cidr_range"></a> [ws\_ld\_vpc\_cidr\_range](#input\_ws\_ld\_vpc\_cidr\_range) | CIDR range for AppStream VPC | `string` | n/a | yes |


-----------

### Bug Fixes or Feature Requests
- Please raise a GitHub Issue with bug fixes or proposed feature requests for the Isolake deployment design.

