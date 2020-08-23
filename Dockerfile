FROM nginx
COPY ./public /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
WORKDIR /usr/share/nginx/html/
RUN chown -R daemon:daemon * && chmod -R 755 *
EXPOSE 80