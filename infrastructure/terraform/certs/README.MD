Cloud Certs Directory
=====================

The certs in this directory were created for certain cloud components. Below is the command used to generate self signed certs to be used for the infrastructure. Valid certs issued by CA's could be used instead.

```bash
openssl req -new -nodes -x509 -subj "/CN=GitLab" -days 3650 -keyout private/gitlab.key -out public/gitlab.crt -extensions v3_ca
```