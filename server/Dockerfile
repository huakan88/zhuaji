FROM dart:stable AS build
WORKDIR /app
COPY packages/zhuaji_sync /packages/zhuaji_sync
COPY server/pubspec.yaml /app/pubspec.yaml
RUN dart pub get
COPY server/ /app/
RUN dart compile exe bin/server.dart -o /out/zhuaji-api

FROM debian:stable-slim
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*
COPY --from=build /out/zhuaji-api /usr/local/bin/zhuaji-api
ENV PORT=8080
EXPOSE 8080
CMD ["zhuaji-api"]
