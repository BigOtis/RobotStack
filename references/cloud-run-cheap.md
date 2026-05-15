# Cheap Cloud Run Defaults

## Default Profile

Use these defaults for low-traffic personal sites unless the user asks otherwise:

- scale to zero by leaving minimum instances at `0`
- set maximum instances to `1`
- start with low memory and CPU allocations
- deploy only one public web service
- keep image uploads in Cloud Storage instead of local disk

## Why

- Minimum instances increase idle cost.
- Maximum instances cap surprise scaling and protect backing services such as MongoDB.
- Cloud Run is a good fit when traffic is bursty and idle time is common.

## Deploy Shape

The helper script uses source deploys and service-level max instances. Raise limits only after observing a real need.

## When To Deviate

- Need lower latency after idle periods: consider minimum instances above zero.
- Need more throughput: raise max instances and revisit database pool sizing.
- Need private content: do not make the image bucket public; use signed URLs or authenticated delivery instead.

