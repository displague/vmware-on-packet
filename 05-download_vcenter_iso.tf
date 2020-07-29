data "template_file" "download_vcenter" {
  template = file("templates/download_vcenter.sh")
  vars = {
    s3_url           = var.s3_url
    s3_access_key    = var.s3_access_key
    s3_secret_key    = var.s3_secret_key
    s3_bucket_name   = var.s3_bucket_name
    vcenter_iso_name = var.vcenter_iso_name
  }
}

resource "null_resource" "download_vcenter_iso" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = chomp(tls_private_key.ssh_key_pair.private_key_pem)
    host        = packet_device.router.access_public_ipv4
  }

  provisioner "file" {
    content     = data.template_file.download_vcenter.rendered
    destination = "/root/download_vcenter.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /root",
      "chmod +x /root/download_vcenter.sh",
      "/root/download_vcenter.sh"
    ]
  }
}
