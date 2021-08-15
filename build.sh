#!/usr/bin/env bash
shopt -s extglob

rm -f VanillAA.zip

zip -r VanillAA.zip !(build.sh)
