terraform {
 backend "gcs" {
   bucket  = "rholcombe-gke-test"
   path    = "/terraform.tfstate"
   project = "rholcombe-gke-test"
 }
}
