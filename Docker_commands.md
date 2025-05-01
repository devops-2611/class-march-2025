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

Create a container from image:
```bash
docker run -d --name welcome-cont -p 8081:80 nginx:alpine 
```
![alt text](image-4.png)


Lists all the container including running and existed:
```bash
docker ps -a 
```

![alt text](image-5.png)



