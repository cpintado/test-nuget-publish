FROM ubuntu:22.04
LABEL org.opencontainers.description="Publishes an empty NuGet package to GitHub Packages"
LABEL org.opencontainers.image.source="https://github.com/cpintado/test-nuget-publish"
LABEL org.opencontainers.image.licenses="MIT"
LABEL maintainer="Carlos Pintado"
LABEL org.opencontainers.image.authors="Carlos Pintado"

WORKDIR /home/build
RUN apt-get update && apt-get install -y dotnet-sdk-6.0 curl
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
