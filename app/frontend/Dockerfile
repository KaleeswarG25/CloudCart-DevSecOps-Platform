# Stage 1: Build the React Application
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the source code and build directories
COPY ./public ./public
COPY ./src ./src
COPY .env.production ./ 2>/dev/null || true

# Compile the React application into static assets
RUN npm run build

# Stage 2: Serve the Static Assets using Nginx
FROM nginx:alpine

# Apply latest OS security patches
RUN apk update && apk upgrade --no-cache

# COPY the compiled build directory from Stage 1 into the Nginx serving root
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]