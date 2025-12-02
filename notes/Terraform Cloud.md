---
created: 2025-11-24
title: Terraform Cloud
tags:
  - terraform
aliases:
---
```
terraform {
	backend "remote" {
		organization = "your-super-puper-org"	
		
		workspaces = {
			name = "terraform-course"	
		}
	}
}
```

- Free up to 5 users
- $20/user/month beyond