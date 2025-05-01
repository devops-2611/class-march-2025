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


Login and run any commmand in container
```bash
docker exec -it welcome-cont sh 
```
![alt text](image-8.png)


pull and run the ubuntu container in detach and interactive terminal mode 
```bash
docker run -dit --name welcome-cont -p 8085:80 ubuntu nginx -g "daemon off;"
```
the above command:
Run nginx in the foreground (nginx -g "daemon off;").

Bind port 8085 on your host to port 80 on the container


![alt text](image-9.png)

go inside the container by using container id 
```bash
docker exec -it <container id> sh
docker exec -it c64928e46ccc sh
```
![alt text](image-10.png)

docker cp command is used to copy files or directories between a Docker container and the host system.
```bash
docker cp /host/path/to/file <container_id>:/path/in/container

docker cp index.html c64928e46ccc:/usr/share/nginx/html/index.html
```
![alt text](image-12.png)

![alt text](image-11.png)










