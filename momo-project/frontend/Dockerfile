FROM node:16-alpine as builder

WORKDIR /momo-store

COPY package.json package-lock.json ./

RUN yarn install 

COPY . .

ENV NODE_ENV=production

ENV VUE_APP_API_URL=https://api.provadm.space

RUN yarn build

FROM nginx:1.23.3

WORKDIR /usr/share/nginx/html/

COPY ./.nginx/nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /momo-store/dist/ ./

RUN mkdir ./momo-store && mv css img js ./momo-store

EXPOSE 8080 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]

