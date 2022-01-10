FROM node:lts-alpine3.14

WORKDIR /consumer
COPY ./ ./

RUN npm install

ENTRYPOINT [ "node", "run.js" ]