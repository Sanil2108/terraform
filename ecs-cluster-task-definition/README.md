# Steps
## 1. Setup IAM roles for EC2 to access ECS

    EC2 instances. needs access to ECS roles so that ECS can keep track of EC2 instances. Need an IAM role for that.

## 2. Setting up a launch configuration

    This defines the ec2 launch related stuff, like image, user data, etc.

## 3. Setting up the ASG

## 4. Setting up the ECS Capacity provider

    This defines the strategy on how tasks are being executed on my cluster infrastructure.

## 5. Setting up the ECS Cluster

## 6. Specifying a task definition

## 7. Run the task using a service