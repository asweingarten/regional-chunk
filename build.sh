#!/bin/bash

elm-make src/Main.elm --output build/commandPalette.js;
cp src/*.js build/;
