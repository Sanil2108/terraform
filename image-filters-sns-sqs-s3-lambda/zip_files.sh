#!/bin/bash
rm -rf *.zip
cd black_white_function
zip -r ../black_white_function.zip *
cd ..

cd contrast_function
zip -r ../contrast_function.zip *
cd ..
