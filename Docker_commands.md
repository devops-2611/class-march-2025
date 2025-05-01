This command will stop all running containers:
```bash
docker stop $(docker ps -q)
```bash
docker rm $(docker ps -a -q)

```bash
docker rmi $(docker images -q)


