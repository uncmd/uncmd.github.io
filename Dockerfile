FROM node:14.8.0-alpine AS build-env
RUN mkdir -p /usr/src/hexo-blog
WORKDIR /usr/src/hexo-blog
COPY . .
RUN npm --registry https://registry.npm.taobao.org install -g hexo-cli && npm install
RUN hexo clean && hexo generate

FROM nginx:latest
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /usr/share/nginx/html
COPY --from=build-env /usr/src/hexo-blog/public /usr/share/nginx/html
EXPOSE 80