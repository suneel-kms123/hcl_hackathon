FROM node:14

# Set the working directory
WORKDIR /usr/src/app

# Copy the app.js file
COPY package*.json ./
RUN npm install \
    && npm install -g serve \
    && npm run build \
    && rm -fr node_modules
COPY patient-service.js .

# Expose the port that the app listens on
EXPOSE 8080

# Define the command to run the app
CMD ["node", "patient-service.js"]