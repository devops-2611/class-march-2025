# Docker Commands

These are some useful Docker commands for managing containers and images.

## Stop Running Containers
This command will stop all running containers:

```bash
docker stop $(docker ps -q)
