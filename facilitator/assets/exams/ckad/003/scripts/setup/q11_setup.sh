#!/usr/bin/env bash
set -euo pipefail
mkdir -p /opt/course/exam3/q11/image /opt/course/exam3/q11

# Seed minimal Dockerfile and Go app (user will modify ENV and build)
cat > /opt/course/exam3/q11/image/Dockerfile <<'EOF'
FROM golang:1.21-alpine as build
WORKDIR /src
COPY . .
RUN go build -o /out/app ./

FROM alpine:3.18
ENV SUN_CIPHER_ID=""
COPY --from=build /out/app /app
CMD ["/app"]
EOF

cat > /opt/course/exam3/q11/image/main.go <<'EOF'
package main
import (
  "fmt"
  "os"
  "time"
)
func main(){
  id := os.Getenv("SUN_CIPHER_ID")
  for { fmt.Printf("SUN_CIPHER_ID=%s\n", id); time.Sleep(2*time.Second) }
}
EOF

