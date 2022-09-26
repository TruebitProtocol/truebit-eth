#!/bin/bash

emcc -o filesystem.wasm -s EXPORTED_FUNCTIONS="['_env____syscall5', '_env____syscall140', '_env____syscall6', '_env____syscall3', '_env____syscall195', '_env____syscall146', \
'_env____syscall4', '_env____syscall41', '_env____syscall63', '_env____syscall330', '_env____syscall145', '_env____syscall333', '_env____syscall197', '_env____syscall221', \
'_env____syscall334', '_env____syscall180', '_env____syscall181', '_env____syscall295', '_env____lock', '_env____unlock', '_env__getenv', \
'_env____syscall54', '_env__pthread_mutex_lock', '_env__pthread_mutex_unlock', '_env__pthread_cond_broadcast', '_env____cxa_atexit',  '_env____cxa_allocate_exception', \
'_initSystem', '_finalizeSystem', '_callArguments', '_callReturns', '_getReturn', '_callMemory', '_env__getInternalFile', \
'_env__pthread_mutex_lock', '_env__pthread_mutex_init', '_env__pthread_mutex_destroy', \
'_env__pthread_mutexattr_init', '_env__pthread_mutexattr_settype', '_env__pthread_cond_init', \
'_env__pthread_mutexattr_destroy', '_env__pthread_condattr_init', \
'_env__pthread_getspecific', '_env__pthread_setspecific', '_env__pthread_condattr_create', '_env__pthread_condattr_setclock', '_env__pthread_condattr_destroy', '_env__pthread_key_create', \
'_env__pthread_mutex_unlock', '_env__pthread_cond_broadcast', '_env__gettimeofday', \
'_wasi_snapshot_preview1_fd_filestat_get', \
'_wasi_snapshot_preview1_fd_read', \
'_wasi_snapshot_preview1_fd_close', \
'_wasi_snapshot_preview1_proc_exit', \
'_wasi_snapshot_preview1_fd_prestat_dir_name', \
'_wasi_snapshot_preview1_fd_write', \
'_wasi_snapshot_preview1_path_open', \
'_wasi_snapshot_preview1_fd_seek', \
'_wasi_snapshot_preview1_fd_fdstat_get', \
'_wasi_snapshot_preview1_environ_get', \
'_wasi_snapshot_preview1_environ_sizes_get', \
'_wasi_snapshot_preview1_args_get', \
'_wasi_snapshot_preview1_random_get', \
'_wasi_snapshot_preview1_clock_time_get', \
'_wasi_snapshot_preview1_args_sizes_get', \
'_wasi_snapshot_preview1_fd_prestat_get', \
'_env__internalSync', '_env__internalSync2']" -s SIDE_MODULE=2 filesystem.c

../ocaml-offchain/interpreter/wasm -orig filesystem.wasm
cp orig.wasm filesystem.wasm
rm orig.wasm
