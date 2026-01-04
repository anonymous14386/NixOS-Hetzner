FROM node:18

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Create data directory and change ownership
RUN mkdir -p data && chown node:node data

# Bundle app source
COPY . .

# Expose port and start app
EXPOSE 3000
CMD [ "node", "index.js" ]
