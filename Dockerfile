FROM nginx:latest
# Απλώς αλλάζουμε το index page για να ξέρουμε ότι είναι το ΔΙΚΟ ΜΑΣ image
RUN echo "<h1>Hello from CI/CD Pipeline!</h1>" > /usr/share/nginx/html/index.html