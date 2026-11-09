#!/usr/bin/env zsh
# Startup-and-exit measurements do not include prompt hooks or deferred plugins.
setopt ERR_EXIT NO_UNSET PIPE_FAIL
zmodload zsh/datetime

samples=${1:-7}
if [[ $samples != <-> ]] || (( samples < 3 || samples > 100 )); then
  print -ru2 -- 'Usage: benchmark-shell.zsh [SAMPLES: 3..100]'
  exit 1
fi
if [[ $OSTYPE != darwin* ]]; then
  print -ru2 -- 'PTY measurements require the macOS script command.'
  exit 1
fi

run_sample() {
  if [[ $mode == non_tty ]]; then
    /bin/zsh -ic exit </dev/null >/dev/null 2>&1
  else
    /usr/bin/script -q /dev/null /bin/zsh -ic exit </dev/null >/dev/null
  fi
}

for mode in non_tty pty; do
  run_sample
  durations=()
  for (( sample=1; sample<=samples; sample++ )); do
    float started=$EPOCHREALTIME
    run_sample
    durations+=("$(( (EPOCHREALTIME - started) * 1000 ))")
  done
  durations=( ${(on)durations} )
  integer middle=$(( (samples + 1) / 2 ))
  float median=$durations[middle]
  if (( samples % 2 == 0 )); then
    median=$(( (median + durations[middle + 1]) / 2 ))
  fi
  printf '%s_median_ms=%.1f\n' "$mode" "$median"
done
print -r -- "samples=$samples (per mode, excluding warmup)"
print -r -- 'Scope: startup-and-exit only; test interactive plugin readiness separately.'
