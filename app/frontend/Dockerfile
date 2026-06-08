FROM nginx:alpine

# Add this step to apply all latest Alpine OS-level security patches
RUN apk update && apk upgrade --no-cache

COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
