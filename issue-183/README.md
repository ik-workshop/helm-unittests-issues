
- [issue 1](https://github.com/helm/helm/issues/8789)
- [issue 2](https://github.com/helm/helm/issues/12606)

To clarify a bit more. This is what happening. The framework is trying to interpret

```yml
ingress.routes: ~
```

Sometimes as

```json
{
  "ingress": { "routes": "~" }
}
```

And sometimes as

```json
{
  "ingress.routes": "~"
}
```
