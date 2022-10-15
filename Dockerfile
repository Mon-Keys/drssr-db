FROM golang:1.18 as builder
COPY . /main
WORKDIR  /main
RUN CGO_ENABLED=0 GOOS=linux go build .

FROM alpine:latest  
WORKDIR /root/
COPY ./forwards  ./forwards
COPY --from=builder /main/migrations ./

ENTRYPOINT [ "./migrations" ]