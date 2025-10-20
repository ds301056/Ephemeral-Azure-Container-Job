# Minimal Node.js container for ephemeral job
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (production only)
RUN npm ci --omit=dev

# Copy application code
COPY . .

# Run the job once and exit
CMD ["npm", "start"]