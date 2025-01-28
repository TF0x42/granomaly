mongodb
=========

**mongodb** - A role for installing and configuring MongoDB on Ubuntu-based systems using Ansible. This role automates the setup of MongoDB, including adding the MongoDB repository, installing the MongoDB package, and ensuring the service is running and enabled.

Requirements
------------

This role assumes that you are using a Debian-based system (like Ubuntu). Specifically, the role is designed to work with  Ubuntu 20.04 (Focal) and Ubuntu 22.04 (Jammy). 

Prerequisites:
- Ansible 2.9 or higher.
- The target host must have internet access to download MongoDB from the official repository.
- `python-apt` package must be installed on the target host if not already present (Ansible usually handles this automatically).

Role Variables
--------------

The following are variables that can be set to customize the MongoDB installation and configuration:

Default Variables (from `defaults/main.yml`):

- `mongodb_version`: The version of MongoDB to install (default: "4.4").
- `mongodb_repo_url`: The URL for the MongoDB repository (default: `https://repo.mongodb.org/apt/ubuntu`).
- `mongodb_repo_arch`: The architecture for MongoDB packages (default: `[ arch=amd64 ]`).
- `mongodb_repo_component`: The repository component for MongoDB (default: `"multiverse"`).

Other Customizable Variables (optional):

- `mongodb_port`: The port MongoDB will listen on (default: `27017`).
- `mongodb_bind_ip`: The IP address MongoDB will bind to (default: `127.0.0.1`).

You can override these variables in your playbook or inventory to suit your environment.

Dependencies
------------

This role does not have any external dependencies. It is designed to work independently and does not rely on any other Galaxy roles.

Example Playbook
----------------

Here is an example of how to use the `mongodb` role in your playbook:

```yaml
---
- hosts: servers
  become: yes
  roles:
    - role: mongodb
      vars:
        mongodb_version: "7.0"
        mongodb_port: 27017
        mongodb_bind_ip: "0.0.0.0"
```

License
-------

BSD

Author Information
------------------

Alexander Schwankner, Research Institute CODE ([https://www.unibw.de/code](https://www.unibw.de/code))
