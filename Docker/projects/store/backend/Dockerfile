# Dockerfile for Node.js Backend
FROM node:18

WORKDIR /usr/src/app

# Copy package files first for better layer caching
COPY package*.json ./

RUN npm install

# Copy the rest of the application
COPY . .

# Environment variables for database connection
ENV DB_HOST=store-db
ENV DB_USER=store_user
ENV DB_PASSWORD=store_password
ENV DB_NAME=store_db
ENV DB_PORT=3306

EXPOSE 5000

CMD ["npm", "start"]