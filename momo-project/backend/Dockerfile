FROM golang:1.17-alpine

WORKDIR /app

COPY . .

RUN go mod tidy

RUN go build -o main cmd/api/*.go

EXPOSE 8081

CMD [ "/app/main" ]
