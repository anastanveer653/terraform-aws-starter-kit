# Security policy

## Supported versions

Security fixes go to the latest release on `main`.

## Reporting a vulnerability

Please report vulnerabilities privately through GitHub's [private vulnerability reporting](https://github.com/anastanveer653/terraform-aws-starter-kit/security/advisories/new). Do not open a public issue.

Include:

- the affected module or file,
- what an attacker could do, and
- steps or configuration to reproduce it.

You can expect an acknowledgement within a few days. Once a fix is merged, you will be credited in the advisory unless you prefer otherwise.

## In scope

- Misconfigurations in the Terraform code that weaken the security of a deployed stack, for example overly broad IAM, missing encryption or unintended network exposure.
- Weaknesses in the CI/CD pipeline, such as the OIDC trust policies or workflow permissions.

## Out of scope

- Findings that the README already lists as accepted risks.
- Vulnerabilities in AWS services, Terraform or the AWS provider. Report those to their maintainers.
