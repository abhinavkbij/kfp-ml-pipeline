terraform {
  backend "gcs" {
    bucket = "learn-experiment-tf-state"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.75.0"
    }
  }
}

provider "google" {
  #   credentials = file("NAME.json")

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name                    = "spot-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_regional_us_central1" {
  name          = "us-central1-subnet"
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# resource "google_service_account" "default" {
#   account_id   = "service_account_id"
#   display_name = "Service Account"
# }

resource "google_compute_instance" "spot_vm_instance" {
  name         = "spot-instance-kfp"
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  scheduling {
    preemptible                 = true
    automatic_restart           = false
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
  }

  network_interface {
    # A default network is created for all GCP projects but we're using above created vpc network and subnetwork
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet_regional_us_central1.id
    access_config {
      
    }
  }
  tags = ["ssh"]

  metadata_startup_script = <<-EOT
  #!/bin/bash
  sudo apt update
  if [ ! python3 -V &> /dev/null ]
  then 
    sudo apt install build-essential libssl-dev libffi-dev python3-dev python3-pip -y
  fi
  sudo apt install git -y
  CLONE_URL=${var.clone_url}
  GH_USERNAME=${var.gh_username}
  GH_TOKEN=${var.gh_token}
  if [ $${CLONE_URL:0:5} = "https" ]
  then
     REPO_URL="$${CLONE_URL:0:8}$GH_USERNAME:$GH_TOKEN@$${CLONE_URL:8}"
     git clone $REPO_URL
     # git@github.com:abhinavkbij/kfp-ml-pipeline
  else
    PARTIAL_URL=$${CLONE_URL:3}
    CR_PARTIAL_URL=$${PARTIAL_URL[@]/://}
    REPO_URL="https://$GH_USERNAME:$GH_TOKEN$CR_PARTIAL_URL"
    git clone $REPO_URL
  fi
  cd kfp-ml-pipeline/kf_pipeline
  if [ pip3 -V &> /dev/null ]; then
    pip3 install -r requirements.txt
    elif [ pip -V &> /dev/null ]; then
      pip install -r requirements.txt
    else
      sudo apt install python3-pip -y && pip install -r requirements.txt
  fi
  EOT
}

resource "google_compute_firewall" "spot_vm_frules" {
  name    = "spot-vm-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["ssh"]

}