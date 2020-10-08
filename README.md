rhcos-ami
=========

Ansible role to create an AWS AMI from a Red Hat CoreOS VMDK or Raw Disk Image

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

| Variable        | Default      | Comments                                 |
| :---            | :---         | :---                                     |
| create_role     | true         | Should the role create the IAM role      |
| vmdk_tmp        | '/tmp'       | Temp location of downloaded VMDK file    |
| rhcos_ver       | '4.5.6'      | RedHat CoreOS Version Number             |
| s3_bucket       | 'mybucket'   | S3 Bucket Name                           |
| cleanup_local   | false        | Delete Downloaded VMDK when complete     |
| cleanup_s3      | false        | Delete VMDK from S3 bucket when complete |
| s3_arn_prefix   | 'arn:aws:s3' | S3 ARN Prefix                            |
| device_name     | '/dev/xvda'  | Image Root Device Name                   |
| volume_size     | '16'         | Image Root Volume Size                   |
| volume_type     | 'gp2'        | Image Root Volume Type                   |


Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

Dan Clark <danclark@redhat.com>

