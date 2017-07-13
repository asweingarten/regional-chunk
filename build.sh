#!/bin/bash

elm-make src/*.elm --output build/commandPalette.js;
cp src/*.js build/;
