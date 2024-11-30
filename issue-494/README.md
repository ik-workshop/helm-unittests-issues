# ISSUE 494

![reproduced issue](./assets/before.png)

```sh
echo hello | openssl enc -base64 # aGVsbG8K
echo -n hello | openssl enc -base64 # aGVsbG8=
// or
echo -n hello | base64 -w 0
```
