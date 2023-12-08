// Cluster with latest version and derby spark configs

resource "databricks_cluster" "example" {
  cluster_name       = "Example Cluster"
  spark_version      = "13.3.x-scala2.12"
  node_type_id       = "i3.xlarge"
  data_security_mode = "SINGLE_USER"
  autoscale {
    min_workers = 1
    max_workers = 2
  }
  spark_conf = {
    "spark.hadoop.javax.jdo.option.ConnectionUserName"   = "admin"
    "spark.hadoop.javax.jdo.option.ConnectionURL"        = "jdbc:derby:memory:myInMemDB;create=true"
    "spark.hadoop.javax.jdo.option.ConnectionDriverName" = "org.apache.derby.jdbc.EmbeddedDriver"
  }
}
