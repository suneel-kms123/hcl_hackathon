FROM node:14

# Set the working directory
WORKDIR /usr/src/app

# Copy the app.js file
COPY appointment-service.js .

# Expose the port that the app listens on
EXPOSE 8081

# Define the command to run the app
CMD ["node", "appointment-service.js"]