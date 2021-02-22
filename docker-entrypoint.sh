#!/bin/bash
set -eo pipefail

_main() {
    service nginx start || true
    service mysite start || true
    exec "$@"
}

_main "$@"