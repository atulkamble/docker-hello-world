# Use the most basic nginx alpine image
FROM nginx:alpine

# Copy HTML files
COPY html /usr/share/nginx/html

# Expose port 80
EXPOSE 80
