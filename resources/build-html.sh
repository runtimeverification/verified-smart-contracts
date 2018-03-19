#!/bin/sh
for doc in $(find . -name '*.md' \! -name 'sum-to-n.md') ; do
  pandoc --lua-filter=resources/relink.lua -so ${doc%.md}.html $doc
done
# build files that have TeX equations
for doc in resources/sum-to-n.md ; do
  pandoc --lua-filter=resources/relink.lua --mathjax=https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-MML-AM_CHTML -so ${doc%.md}.html $doc
done
