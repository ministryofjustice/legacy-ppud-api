# PPUD Database Sync Runbook

This page contains notes detailing what the alerts for the PPUD database sync mean and how we can go about resolving things...

## Database Sync Failure

> The PPUD database sync for `<environment>` has been in a failed state for more than XX minutes.

This means that the PPUD database sync (managed by the AWS database migration service) has failed.

To check that this is the case, and to see the reported error message (from the sync), run the following command in the root of this repo (substituting in the correct environment):

```sh
./scripts/check-ppud-replication.sh -e <environment>
```

If it's an intermittent issue you can restart the sync job with the following:

```sh
./scripts/start-ppud-replication.sh -e <environment>
```

Otherwise we'll need to research the issue and potentially work with Lumen to resolve (if it's an issue their end).

## Database Sync Reporting Failure

> The PPUD database sync check for `<environment>` hasn't reported in for more than XX minutes.

This means that the PPUD database sync may still be functioning properly, the prometheus push gateway we use to report on its progress has failed or prometheus (managed by the cloud platform team) is not scraping its metrics correctly.

First, see if the push gateway is up and running:

```sh
kubectl -n ppud-replacement-<environment> get pods
```

You're looking for a single pod called something like `ppud-replacement-dev-pushgateway-prometheus-pushgateway-xxxxxxx`...

If this is NOT running (i.e. it's crashlooping) check the logs for the pod to see if you can find out why (`kubectl -n ppud-replacement-<environment> logs <pod-name>`) and see if you can resolve. If you need help, [#ask-cloud-platform] is your friend.

If pod is there and running correctly, it means we have a metric scraping issue. If you've not diagnosed these in prometheus before, your best bet is to ask for help in [#ask-cloud-platform].

If the pod is not even present, it means something has gone wrong with the terraform in the [cloud-platform-environments] repo - if you're not familiar with terraform, your best bet is to ask for help in [#ask-cloud-platform].

[#ask-cloud-platform]: (https://mojdt.slack.com/archives/C57UPMZLY)
[cloud-platform-environments]: (https://github.com/ministryofjustice/cloud-platform-environments)
