# Define the AWS provider configuration.
provider "aws" {
  region = "ap-south-1"  # Replace with your desired AWS region.
}

resource "aws_instance" "server" {
  ami           = "ami-00bb6a80f01f03502"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  key_name      = "keypair"  # Replace with your existing AWS key pair name
  security_groups = ["sg-0d5afbea96dccacb6"]  # Replace with your security group ID
  subnet_id     = "subnet-038b8d3c4cc108b44"  # Replace with your subnet ID

  # Connection block for SSH access
  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("${path.module}/keypair.pem")  # Ensure this is the converted .pem key
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
 provisioner "file" {
    source      = "${path.module}/app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

  # Remote-exec provisioner to execute commands on the EC2 instance
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",  # Update package lists (for Ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation,
      "sudo apt install python3-flask -y",  # Install Flask
      "nohup sudo python3 /home/ubuntu/app.py &",  # Run the Python app
    ]
  }

  tags = {
    Name = "MyServer"
  }
}

output "instance_public_ip" {
  value = aws_instance.server.public_ip
}
