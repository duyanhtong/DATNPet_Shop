# # Sử dụng NodeJS image làm base image
# FROM node:latest

# # Create app directory
# WORKDIR /usr/src/app

# # Install app dependencies
# COPY package*.json ./

# RUN npm install

# # Bundle app source
# COPY . .

# RUN npm run build



# EXPOSE 4000

# CMD [ "npm", "run" , "start:prod" ]
# Sử dụng NodeJS image làm base image
FROM node:latest

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./

RUN npm install

# Bundle app source
COPY . .

# Build the app
RUN npm run build

# Copy entrypoint script
COPY entrypoint.sh /usr/src/app

# Grant execute permissions to the entrypoint script
RUN chmod +x /usr/src/app/entrypoint.sh

EXPOSE 4000

# Set the entrypoint
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

# CMD để chỉ định lệnh mặc định khi container chạy
CMD [ "npm", "run", "start:prod" ]
