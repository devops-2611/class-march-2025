To Stop all the containers: 
```bash
docker stop $(docker ps -q)
```
To delete all the containers: 
```bash
docker rm $(docker ps -a -q)
```
To delete all the images:
```bash
docker rmi $(docker images -q)
```
create and pull image from dockerhub:
![alt text](image-2.png)

List images:
```bash
docker images
```
![alt text](image-3.png)
