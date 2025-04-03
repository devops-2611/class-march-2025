# Use a specific Node.js version base image
FROM node:16

# Set the working directory
WORKDIR /app

# Copy your package.json and package-lock.json to install dependencies first
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of your application
COPY . /app

# Expose the required ports
EXPOSE 80
EXPOSE 8080

# Start the server
CMD ["node", "server.js"]
