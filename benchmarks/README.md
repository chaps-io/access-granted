# Benchmark results

Benchmarks ran on MacBook Pro M1 Pro 2021, 32 GB RAM on Ruby 3.2.

## permissions.rb

This benchmark runs `can?` method for the 3 user roles for 20 seconds each, for both CanCan and AccessGranted.

```
Warming up --------------------------------------
            ag-admin   358.693k i/100ms
        ag-moderator   359.044k i/100ms
             ag-user   360.627k i/100ms
        cancan-admin    30.797k i/100ms
    cancan-moderator    26.825k i/100ms
         cancan-user    37.946k i/100ms
Calculating -------------------------------------
            ag-admin      3.640M (± 0.3%) i/s -     18.293M in   5.025691s
        ag-moderator      3.642M (± 0.4%) i/s -     18.311M in   5.027575s
             ag-user      3.643M (± 0.3%) i/s -     18.392M in   5.049271s
        cancan-admin    308.383k (± 0.7%) i/s -      1.571M in   5.093398s
    cancan-moderator    270.716k (± 0.8%) i/s -      1.368M in   5.053863s
         cancan-user    383.198k (± 0.7%) i/s -      1.935M in   5.050472s
```
