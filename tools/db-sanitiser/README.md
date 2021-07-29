# db-sanitiser

This is a simple ruby script (and docker image) used to fully sanitise
the PPUD UAT database received from Lumen as some of the information
inside it was real production data.

# Usage

Simply apply the `job.yaml` in the correct kubernetes namespace and the
script will make it's changes to the database configured in the
`ppud-replica-database` secret.

```
kubectl -n ppud-replacement-preprod apply -f job.yaml
```

You can check on progress by tailing the logs etc. Once the script has run
to completion the job will stop and show a success/fail status.
