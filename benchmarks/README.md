# Benchmark results

Benchmarks ran on Ubuntu 17.04 64bit, i7 6700k @ 4.0Ghz, 32 GB RAM with Ruby 2.3.

## permissions.rb

This benchmark runs `can?` method for the 3 user roles for 20 seconds each, for both CanCan and AccessGranted.

```
Warming up --------------------------------------
            ag-admin   158.815k i/100ms
        ag-moderator   161.055k i/100ms
             ag-user   161.670k i/100ms
        cancan-admin    14.865k i/100ms
    cancan-moderator    13.181k i/100ms
         cancan-user    18.907k i/100ms
Calculating -------------------------------------
            ag-admin      2.141M (± 3.9%) i/s -     10.799M in   5.052573s
        ag-moderator      2.180M (± 2.1%) i/s -     10.952M in   5.025727s
             ag-user      2.206M (± 0.4%) i/s -     11.155M in   5.056550s
        cancan-admin    158.288k (± 2.4%) i/s -    802.710k in   5.074299s
    cancan-moderator    142.573k (± 2.1%) i/s -    724.955k in   5.087277s
         cancan-user    204.783k (± 2.2%) i/s -      1.040M in   5.080488s
```
