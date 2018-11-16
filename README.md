terraform-topologies
---

Reference terraform topologies for future deployments.
Take it and use it

## Topologies

#### General
General example topologies
1. **Modules**: Using modules and local_exec
2. **Backends**: Using backends

#### AWS
Amazon web services specific.

1. **Instance with Ip**: Single instance with elastic ip
![img](./aws/instance-with-ip/instance-ip.png)
2. **instance-with-provision-and-key-pair**: Single instance with elastic ip and local provision with ssh keys.
3. **Setup security groups**: Security Group.
4. **Instance with EBS**: Instance with EBS volume.
5. **VPC**: See [article](https://dev.to/duduribeiro/creating-your-cloud-servers-with-terraform-2lpd)
![img](./aws/vpc-example/vpc-1.png)


## LICENCE
Copyright © 2017 Theo Despoudis MIT license