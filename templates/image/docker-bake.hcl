target "__IMAGE__" {
  inherits = ["_common"]
  context  = "images/__IMAGE__"
  tags     = ["${REGISTRY}/__IMAGE__:${TAG}"]
}
