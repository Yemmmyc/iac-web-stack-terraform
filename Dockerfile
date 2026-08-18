FROM nginx:alpine

LABEL maintainer="IaC Web Stack"
LABEL description="Terraform-managed web application"

COPY app/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1
