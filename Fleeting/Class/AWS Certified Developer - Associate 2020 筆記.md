---
tags: AWS, Learning
---

# AWS Certified Developer - Associate 2020 筆記

## The Exam Blueprint

|Objectiv |Weighting |
|--|--
|Deployment| 22%|
|Security| 26%|
|Devlelopment with AWS Services |30%|
|Refactoring |10%|
[AWS Certified Developer – Associate
(DVA-C01) Exam Guide](https://d1.awsstatic.com/training-and-certification/docs-dev-associate/AWS-Certified-Developer-Associate_Exam-Guide.pdf)

- 130 Minutes in Length
- 65 Questions
- Results immediately
- Passmark is 720. Top Score 1000
- $150 USD
- Multiple Choice
- Qualification is valid for 2 years

## IAM 101
### What is IAM
IAM allows you to manage users and their level of access to AWS Console.

- Centrailzed control of your AWS account 
- Shared Access to your AWS account
- Granular Permissions
- Indentity Federation (Including AD, FB, Linkedin...)
- MFA
- Provides temporary access for uers/devices and services, as necessary
- Allows you to set up your own password roation policy
- Support PCI DSS Compliance

### Critical Terms:
- Users - End Users (people who logged in AWS Console)
- Groups - A collections of users under one set of permissions
- Roles - defined to assign a set of permission of accessing AWS resources
- Policies - A document that defines one or more permissions,
    - can be attached to users, groups and users

### Resources
- [考古](https://www.briefmenow.org/amazon/category/exam-aws-saa-update-july-14th-2017/)