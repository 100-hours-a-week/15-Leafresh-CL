project_id            = "leafresh-dev"
region                = "asia-northeast3"
zone                  = "asia-northeast3-a"
instance_name         = "leafresh-gce-db"
machine_type          = "e2-custom-1-3072"

network               = "leafresh-vpc-dev"
subnetwork            = "leafresh-db-subnet-dev"

service_account_email = "1096531471969-compute@developer.gserviceaccount.com" 
mysql_root_password   = "Rlatldms!2!3"
mysql_database        = "leafresh"