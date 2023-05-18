#! /bin/sh

set -e

system_profiler -json -detailLevel full SPFontsDataType > Sources/FontBook/fonts.json
