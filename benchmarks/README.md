# Benchmark results

Benchmarks ran on Ubuntu 15.04 64bit, i5 2500k @ 4.4Ghz, 16 GB RAM with Ruby 2.2.

## permissions.rb

This benchmark runs `can?` method for the 3 user roles for 20 seconds each, for both CanCan and AccessGranted.

```
Calculating -------------------------------------
            ag-admin    21.361k i/100ms
        cancan-admin    13.631k i/100ms
        ag-moderator    22.328k i/100ms
    cancan-moderator    11.679k i/100ms
             ag-user    25.860k i/100ms
         cancan-user    16.308k i/100ms
-------------------------------------------------
            ag-admin    283.174k (± 1.1%) i/s -      5.682M
        cancan-admin    160.450k (± 1.0%) i/s -      3.217M
        ag-moderator    301.290k (± 1.1%) i/s -      6.029M
    cancan-moderator    134.591k (± 1.3%) i/s -      2.698M
             ag-user    353.259k (± 0.9%) i/s -      7.086M
         cancan-user    198.579k (± 1.6%) i/s -      3.979M
```
