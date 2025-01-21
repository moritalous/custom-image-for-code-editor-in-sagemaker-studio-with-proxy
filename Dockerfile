# Reference: https://docs.aws.amazon.com/sagemaker/latest/dg/code-editor-custom-images-specifications.html

FROM public.ecr.aws/sagemaker/sagemaker-distribution:latest-cpu

ARG NB_USER="sagemaker-user"
ARG NB_UID=1000
ARG NB_GID=100
ENV MAMBA_USER=$NB_USER

USER root

RUN apt-get update && apt-get install -y nginx

ADD nginx-proxy.conf /etc/nginx/sites-enabled/

RUN sed -i 's/8888/18888/g' /usr/local/bin/start-code-editor

RUN sed -i '/^user www-data;/d' /etc/nginx/nginx.conf 
RUN sed -i 's|/run/nginx.pid|/tmp/nginx.pid|g' /etc/nginx/nginx.conf 
RUN rm /etc/nginx/sites-enabled/default

RUN echo '' >> "/etc/supervisor/conf.d/supervisord-code-editor.conf" && \
    echo '[program:nginx]' >> "/etc/supervisor/conf.d/supervisord-code-editor.conf" && \
    echo 'command=nginx -g "daemon off;"' >> "/etc/supervisor/conf.d/supervisord-code-editor.conf" && \
    echo 'autostart=true' >> "/etc/supervisor/conf.d/supervisord-code-editor.conf" && \
    echo 'autorestart=true' >> "/etc/supervisor/conf.d/supervisord-code-editor.conf"

RUN chown -R 1000:100 /var/lib/nginx
RUN chmod -R 750 /var/lib/nginx
RUN chown -R 1000:100 /var/log/nginx
RUN chmod -R 750 /var/log/nginx

USER $MAMBA_USER
ENTRYPOINT ["entrypoint-code-editor"]
