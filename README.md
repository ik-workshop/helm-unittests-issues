# Workshop Helm Unittest

---

![](https://img.shields.io/github/commit-activity/m/ik-workshop/helm-unittests-issues)
![](https://img.shields.io/github/last-commit/ik-workshop/helm-unittests-issues)
[![](https://img.shields.io/github/license/ivankatliarchuk/.github)](https://github.com/ivankatliarchuk/.github/LICENCE)
[![](https://img.shields.io/github/languages/code-size/ik-workshop/helm-unittests-issues)](https://github.com/ik-workshop/helm-unittests-issues)
[![](https://img.shields.io/github/repo-size/ik-workshop/helm-unittests-issues)](https://github.com/ik-workshop/helm-unittests-issues)
![](https://img.shields.io/github/languages/top/ik-workshop/helm-unittests-issues?color=green&logo=markdown&logoColor=blue)


---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [Create](#create)
- [Resources](#resources)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

## Create

[**Create a repository using this template →**][template.generate]

## Resource

- [Helm unittest](https://github.com/helm-unittest/helm-unittest/tree/main)

## Resources

<!-- resources -->
[template.generate]: https://github.com/ik-workshop/helm-unittests-issues/generate
[code-style.badge]: https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square

[governance-badge]: https://github.com/ik-workshop/helm-unittests-issues/actions/workflows/governance.bot.yml/badge.svg
[governance-action]: https://github.com/ik-workshop/helm-unittests-issues/actions/workflows/governance.bot.yml

[governance.link-checker.badge]: https://github.com/ik-workshop/helm-unittests-issues/actions/workflows/governance.links-checker.yml/badge.svg
[governance.link-checker.status]: https://github.com/ik-workshop/helm-unittests-issues/actions/workflows/governance.links-checker.yml

`runAsNonRoot` is set to `false` but `runAsUser` is not set to `0`

   # - failedTemplate:
    #     errorMessage: "`runAsNonRoot` is set to `true` but `runAsUser` is set to `0` (root)"
    # - failedTemplate:
    #     errorMessage: "\\\(root\\\)"
    # - failedTemplate:
    #     errorPattern: |-
    #       \\(root\\)

        - failedTemplate:
        errorPattern: "`runAsNonRoot` is set to `true` but `runAsUser` is set to `0` (root)"
    - failedTemplate:
        errorMessage: "`runAsNonRoot` is set to `true` but `runAsUser` is set to `0` (root)"
