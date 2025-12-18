FROM ubuntu:jammy

RUN apt-get update -y && apt install -y netcat-openbsd

COPY long-echo.sh /long-echo.sh

CMD ["bash", "-c", "/long-echo.sh"]
