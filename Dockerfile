FROM gradle:5.4.1-alpine as builder

USER root

ENV APP_DIR /app
WORKDIR $APP_DIR

COPY build.gradle.kts $APP_DIR/
COPY settings.gradle.kts $APP_DIR/

RUN gradle dependencies

RUN apk add --no-cache curl

RUN curl -O "http://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip" && \
    unzip newrelic-java.zip

COPY . $APP_DIR

# -----------------------------------------------------------------------------

FROM openjdk:12-alpine3.9

RUN apk add --no-cache tini

WORKDIR /app

COPY --from=builder /app/init.sh /app
COPY --from=builder /app/build/libs/newtion-*.jar /app/
COPY --from=builder /app/newrelic/newrelic.jar /app/
COPY --from=builder /app/newrelic/newrelic.yml /app/

EXPOSE 8080

#ENTRYPOINT ["tini", "-s", "--", "sh", "init.sh"]