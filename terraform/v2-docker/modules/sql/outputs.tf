output "leafresh_db_internal_ip"{
    description = "leafresh GCE DB 인스턴스 내부 IP 주소"
    value = google_compute_instance.leafresh_gce_db.network_interface[0].network_ip
}