target "hello" {
  inherits = ["_common"]
  context  = "images/hello"
  tags     = ["${REGISTRY}/hello:${TAG}"]
}
