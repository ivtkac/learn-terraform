---
created: 2025-11-21
title: Ти запустив EC2 інстанс через тераформ, як найти айпі того інстанса?
tags:
  - question
  - aws
  - terraform
  - devops
aliases:
---
- блок output у тераформі-коді, щоб експортувати необхідну інформацію, як [[IP]]

```bash
terraform output public_ip
terraform output private_ip
```

```bash
terraform state show aws_instance.web_server
```

```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=instance-name" --query "Reservations[].Instances[].PublicIpAddress" --output text
```