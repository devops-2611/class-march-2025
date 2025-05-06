# Dockerfile for React Frontend
FROM node:18 as build

WORKDIR /usr/src/app

# Copy package files first for better caching
COPY package*.json ./
COPY index.html ./

# Install dependencies
RUN npm install

# Copy the rest of the files
COPY public ./public
COPY src ./src

# Build the app
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built app
COPY --from=build /usr/src/app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]