FROM golang:1.21.3-alpine3.18 AS build

WORKDIR /root
COPY src/warapong-pj/mtl_assignment/ /root
RUN go build

FROM alpine:3.18.5

RUN adduser -g app app -D -s /bin/nologin
WORKDIR /home/app
USER app:app
COPY --from=build /root/mtl_assignment /home/app/app

CMD [ "/home/app/app" ]
