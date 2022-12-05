FROM node:carbon
WORKDIR /usr/src/app
COPY package*.json ./
COPY .env-node1 ./
RUN npm install
COPY . .
# RUN rm -rf /usr/src/app/config/config
CMD [ "node", "server.js" ]
