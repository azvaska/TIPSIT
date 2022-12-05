FROM node:carbon
WORKDIR /usr/src/app
COPY package*.json ./
COPY .env-node2 ./
RUN npm install
COPY . .
# RUN rm -rf /usr/src/app/config/data
CMD [ "node", "server.js" ]
