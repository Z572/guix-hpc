FROM alpine
RUN apk add --update bash curl jq sed
# Create a group and user
RUN addgroup -S gitlab && adduser -S gitlab -G gitlab
# Create a directory where ci jobs are performed
RUN mkdir /builds && \
    chown -R gitlab:gitlab /builds && \
    chmod g+s /builds
# default user
USER gitlab
# default working directory
WORKDIR /builds
