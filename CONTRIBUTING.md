# Contributing

Thanks for helping improve the kit. Bug reports, fixes and new modules are all welcome.

## Before you start

For anything bigger than a small fix, open an issue first so we can agree on the approach before you write the code.

## Setup

You need:

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.11
- [tflint](https://github.com/terraform-linters/tflint)
- [trivy](https://trivy.dev)
- [terraform-docs](https://terraform-docs.io)
- Optionally [pre-commit](https://pre-commit.com), which runs the same checks on every commit: `pre-commit install`

No AWS account is needed to develop or test: the test suite runs against a mocked provider.

## Making a change

1. Branch from `main`.
2. Make the change. If it alters behaviour, add or update a case in [`tests/main.tftest.hcl`](tests/main.tftest.hcl).
3. Run `make docs` if you changed any variable or output.
4. Run `make check`. It runs everything CI runs: fmt, validate, test, tflint, trivy and the docs check.
5. Open a pull request and fill in the template.

## Conventions

- **Module layout.** Each module has `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` and a `README.md` whose tables come from terraform-docs.
- **Inputs.** Every variable has a `description` and a `type`. Validate anything a user can get wrong, with an error message that says what a valid value looks like.
- **Collections.** Use `for_each` with stable keys (such as the AZ name), not `count` over a list, so that removing one item never renumbers the others.
- **Security.** New resources must pass trivy at medium severity and above. If a finding really is an accepted risk, suppress it inline with `#trivy:ignore:<ID>` and a comment explaining why, and add it to the README's accepted-risks list.
- **Comments.** Explain why, not what.
- **Commits.** Use [Conventional Commits](https://www.conventionalcommits.org): `feat(waf): add geo blocking`, `fix(alb): ...`, `docs: ...`.

## Reporting security issues

Please do not open a public issue for these. See [SECURITY.md](SECURITY.md).
