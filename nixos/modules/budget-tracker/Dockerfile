FROM node:18
 
# Create app directory
WORKDIR /usr/src/app
 
# Create data directory and change ownership
USER root
RUN mkdir -p /usr/src/app/data && chown -R node:node /usr/src/app/data
USER node
 
# Install app dependencies
COPY package*.json ./
RUN npm install
 
# Bundle app source
COPY . .
 
# Expose port and start app
EXPOSE 3000
CMD [ "node", "index.js" ]