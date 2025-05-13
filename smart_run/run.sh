#!/bin/bash
for i in {1..95}; do
    echo "        7'd${i} : get_preg_value = \\\`preg${i};"
done > preg_macros.vh
