SHA1_LOCK_FILE := $(abspath $(CURDIR)/../../protogen/buf.sha1.lock)

# 1. LOCAL_BIN を設定
LOCAL_BIN := C:/msys64/home/kondou/go/bin

.PHONY: protoc-deps
protoc-deps: $(BINGO)
	@cd ../.. && GOPATH="" GOBIN="$(LOCAL_BIN)" # $(BINGO) get google.golang.org/protobuf/cmd/protoc-gen-go
	@cd ../.. && GOPATH="" GOBIN="$(LOCAL_BIN)" # $(BINGO) get ://github.com
	@cd ../.. && GOPATH="" GOBIN="$(LOCAL_BIN)" # $(BINGO) get github.com/owncloud/protoc-gen-microweb
	@cd ../.. && GOPATH="" GOBIN="$(LOCAL_BIN)" # $(BINGO) get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	@cd ../.. && GOPATH="" GOBIN="$(LOCAL_BIN)" # $(BINGO) get github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc
	@cd ../.. && GOPATH="" GOBIN="$(LOCAL_BIN)" # $(BINGO) get github.com/favadi/protoc-go-inject-tag

.PHONY: buf-generate
buf-generate: $(SHA1_LOCK_FILE)
	@find $(abspath $(CURDIR)/../../protogen/proto/) -type f -print0 | sort -z | xargs -0 sha1sum > buf.sha1.lock.tmp
	@cmp $(SHA1_LOCK_FILE) buf.sha1.lock.tmp --quiet || $(MAKE) -B $(SHA1_LOCK_FILE)
	@rm -f buf.sha1.lock.tmp

$(SHA1_LOCK_FILE): $(BUF) protoc-deps
	@echo "generating protobuf content"
	# ↓ $(LOCAL_BIN) を PATH に加えることで、protoc-deps で用意したプラグインが見えるようにする
	cd ../../protogen/proto && PATH="$(LOCAL_BIN):$(PATH)" $(BUF) generate
	# ↓ 生成が成功したら、現在のProtoの状態を記録して「ゴール」とする
	find $(abspath $(CURDIR)/../../protogen/proto/) -type f -print0 | sort -z | xargs -0 sha1sum > $(SHA1_LOCK_FILE)

