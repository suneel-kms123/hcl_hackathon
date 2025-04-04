FROM node:20.0-slim

# Set the working directory
WORKDIR /usr/src/app

COPY package*.json ./
# Copy the app.js file
COPY appointment-service.js .

RUN npm install \
    && npm install -g serve \
    && npm run-script build \
    && rm -fr node_modules

# Expose the port that the app listens on
EXPOSE 8081

# Define the command to run the app
CMD ["node", "appointment-service.js"]