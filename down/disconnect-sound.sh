#!/usr/bin/env bash

declare project_root="$(dirname $(dirname $0))"

play "${project_root}/audio/dtmf-dialtone.wav" repeat 20
