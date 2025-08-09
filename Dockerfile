# Use a slim Node.js image
FROM node:18-slim

# Set the working directory in the container
WORKDIR /app

# Enable corepack for Yarn PnP
RUN corepack enable

# Copy and extract the pre-populated dependency cache
# This assumes vendor/yarn-cache.tgz contains the .yarn directory and .pnp.cjs file
COPY vendor/yarn-cache.tgz .
RUN tar -xzf yarn-cache.tgz && rm yarn-cache.tgz

# Copy the rest of the project source code
COPY . .

# Expose the port the NestJS app will run on
EXPOSE 3000

# Define the default command to run the backend dev server
CMD ["yarn", "dev"]
