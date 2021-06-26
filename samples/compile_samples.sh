# This script compile all example code using the truebit/compiler image.

# Compile Security Example
docker run \
--rm \
-e RUNTIME=c \
-v "$PWD/c/security:/input" \
-v "$PWD/compiled/c/security:/output" \
truebit/compiler


# Compile pairing example
docker run \
--rm \
-e RUNTIME=c \
-v "$PWD/c/pairing:/input" \
-v "$PWD/compiled/c/pairing:/output" \
truebit/compiler


# Compile ffmpeg example
docker run \
--rm \
-e RUNTIME=c \
-v "$PWD/c/ffmpeg:/input" \
-v "$PWD/compiled/c/ffmpeg:/output" \
truebit/compiler


# Compile chess example
docker run \
--rm \
-e RUNTIME=c \
-v "$PWD/c/chess:/input" \
-v "$PWD/compiled/c/chess:/output" \
truebit/compiler


# Compile scrypt example
docker run \
--rm \
-e RUNTIME=c \
-v "$PWD/c/scrypt:/input" \
-v "$PWD/compiled/c/scrypt:/output" \
truebit/compiler


# Compile Rust Reverse Alphabet Example
docker run \
--rm \
-e RUNTIME=rust \
-v "$PWD/rust/reverse_alphabet:/input" \
-v "$PWD/compiled/rust/reverse_alphabet:/output" \
truebit/compiler


# Compile RUST Wasm Example
docker run \
--rm \
-e RUNTIME=rust \
-v "$PWD/rust/wasm:/input" \
-v "$PWD/compiled/rust/wasm:/output" \
truebit/compiler



