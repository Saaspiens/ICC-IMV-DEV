# FROM registry.oneicc.vn/system/node:10-alpine3.11-python-gcc AS node-build
# LABEL maintainer="giangtlt <giang.truong200493@gmail.vn>"

# ##### copy source from branch need build #######
# COPY src-branch-build/SRC/Frontend/ /app/
# ################################################

# WORKDIR /app/fsm
# COPY app-config.json /app/fsm/src/app-configs/app-config.json
# COPY app-config.scss /app/fsm/src/app-configs/app-config.scss

# RUN cat /app/fsm/src/app-configs/app-config.json
# RUN cat /app/fsm/src/app-configs/app-config.scss
# RUN npm i -f
# RUN npm run build-prod
# RUN ls -l /app/fsm/src/

FROM nginx:alpine

COPY dist/ /usr/share/nginx/html/

##### copy nginx conf from branch dev.cicd #######
COPY nginx.conf /etc/nginx/conf.d/default.conf
##################################################

RUN apk --no-cache add --update \
    && apk --no-cache add curl \
    && apk --no-cache add busybox-extras \
    && apk --no-cache add tzdata \
    && rm -rf /var/cache/apk/*

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
