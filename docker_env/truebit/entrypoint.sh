#!/bin/bash
mkdir -p /truebit-eth/logs
tmux new -d -s Truebit \; split-window -d 50 \; split-window -d \; split-window -h

tmux send-keys -t Truebit.2 "cd /truebit-eth && ./truebit-os 2>&1 | tee logs/os.txt" ENTER

if [ -n "$TRUEBIT_SOLVER" ]; then
  if [[ -z "$TRUEBIT_SOLVER_ACCOUNT" ]]; then
    echo "ERROR: $TRUEBIT_SOLVER environment was set but coult not find $TRUEBIT_SOLVER_ACCOUNT"
  else
    tmux send-keys -t Truebit.0 "cd /truebit-eth && ./truebit-os -c \"start solve -a $TRUEBIT_SOLVER_ACCOUNT\" --batch | tee logs/solver.log" ENTER
  fi

fi

if [ -n "$TRUEBIT_VERIFIER" ]; then
  if [[ -z "$TRUEBIT_VERIFIER_ACCOUNT" ]]; then
    echo "ERROR: TRUEBIT_VERIFIER environment was set but coult not find TRUEBIT_VERIFIER_ACCOUNT"
  else
    tmux send-keys -t Truebit.1 "cd /truebit-eth && ./truebit-os -c \"start verify -a $TRUEBIT_VERIFIER_ACCOUNT\" --batch | tee logs/verifier.log" ENTER
  fi

fi

tmux send-keys -t Truebit.2 "task -f tasks/reverse_alphabet/reverse.json submit" ENTER

sleep 1000
ls -la /truebit-eth/logs
tail -f /truebit-eth/logs/solver.txt