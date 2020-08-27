# node环境镜像
FROM node:14.8.0-alpine

ADD . /app

WORKDIR /app

COPY . .

RUN npm config set unsafe-perm true && \
npm config set registry https://registry.npm.taobao.org && \
npm install -g hexo-cli && \
# hexo clean && \
cd src && \
npm install hexo --save && \
npm install hexo-neat --save && \
npm install --save hexo-wordcount && \
npm i -S hexo-prism-plugin && \
npm install hexo-generator-search --save && \
hexo generate && \
npm install hexo-server --save

WORKDIR /src

ENTRYPOINT ["hexo", "server", "-p", "8000"]