# Use the official Apache Tomcat image as the base
FROM tomcat:11.0.2-jdk17-temurin

# Remove the default Tomcat web applications to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your local .war file into the Tomcat webapps directory
COPY ./target/calcwebapp.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat in the foreground
CMD ["catalina.sh", "run"]
