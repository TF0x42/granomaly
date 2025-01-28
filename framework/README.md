# Framework

This folder contains a framework for easy use. It can either be used with VSphere or QEMU. In this README you will find instructions for using the framework. Within the folders there are shorter README files that only contain basic information.

## Project structure
Below is a basic overview of the framework structure:

```
framework/
├── ansible/
│   ├── mongodb/
│   ├── open5gs/
│   ├── hosts
│   ├── host.yml
│   ├── open5gs.yml
│   └── playbook.yml
├── packer/
│   ├── ubuntu-22.04.05-jammy/
│   ├── ubuntu-24.04.01-noble/
├── terraform/
│   ├── main.tf
│   ├── README.md
│   ├── terraform.tfvars-example
│   └── variables.tf

```

## How to build using QEMU with ubuntu-22.04.05-jammy or ubuntu-24.04.01-noble

Before you start, make sure that your CPU supports virtualization. To check on ubuntu use the following command:
```
lscpu
```
Look for the Virtualization section in the output. If it shows VT-x or AMD-V, then virtualization is enabled.

### Setup project

Next you need to add a file in packer/ubntu-22.04.05-jammy or ubuntu-24.04.01-noble (depending on your system), named "variables.pkrvars.hcl" you can do that based on the "variables.pkrvars.hcl-example-qemu". It is crucial that the given parameters match the ones used in the "qemu.auto.pkr.hcl" file. You will at least need to change the password in both files. For that you can use a plaintext or us "mkpasswd" to create an ecrypted password.

For password encryption:

```
sudo apt-get install whois
mkpasswd --method=SHA-512
```

If you use a encrypted password youu need to put " ` " infront and behind the password to use it. 

### Build VM-Image-Template

To build the VM-Image cd into the packer folder:

```
cd .../framework/packer/ubuntu-22.04.05-jammy

or

cd .../framework/packer/ubuntu-24.04.01-noble
```

and then execute the build with:

```
./build_command.txt
```

### Use Terraform for deployment

With the VM-Template created with packer we can now deploy preconfigured VMs using Terraform.

To use Terraform, first you need to add a file called "terraform.tfvars" in which you define the variables given in "variables.tf". The only two variables that you definitly need to change are the "ssh_password" and the "image_source_path" variable. To get the right path for the image cd into the folder where packer safed the ubuntu-template and use "pwd" to get the path.

After setting up the "terraform.tfvars" file, terraform is ready to use just cd into the terraform folder and use the following cmds.


Prepare the plugins und requirements with:

    terraform init

Check the config with:

    terraform plan

Deploy the machines with:

    terraform apply

If you want to delete the deployed machines use:

    terraform destroy

or

    virsh list --all
    virsh destroy lab-1
    virsh undefine lab-1

Just edit lab-1 to the name of your VM

#### Troubleshooting in Terraform

A common issue can occur with libvirt permissions. Should you receive a Error looking something like this:

```
Error: error creating libvirt domain: internal error:
Could not open '/var/lib/libvirt/images/ubuntu.qcow2': Permission denied
```

You probably need to update the security_driver.

Open the configuration File:
```
sudo nano /etc/libvirt/qemu.conf
```

Update the security driver:
```
security_driver = "none"
```

Save and Close the File.

Restart the libvirtd Service:
```
sudo systemctl restart libvirtd
```

### Configuration using Ansible

After deploying the VMs with Terraform, the last step is to use ansible for the configuration.

For the Credentials you need to add a file named "vars.yml" for this you can use the example file. You need to change the "ansible_user", "ansible_ssh_pass" and the "ansible_become_path" to the Credentials you used before. Otherwise ansible cant connect to your VM.

If your VM have other IP-Addresses then the ones used inside the "hosts.yml" file, you will need to change them as well, this also includes the template files, for example "scp.yaml.j2". To check the IP-Addresses of your VMs you can use this cmd:

```
virsh domifaddr lab-1
```

Just edit "lab-1" to the name of your VM

After correctly setting the variables and the IP-Addresses you can use:

```
ansible-playbook open5gs.yml -i hosts.yml
```

to run your playbook.

To check all hosts you can use:

```
ansible-inventory -i /path/to/your/hosts.yml --list
```