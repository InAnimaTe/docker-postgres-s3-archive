### docker-postgres-s3-archive

Taken from [siomiz/postgresql-s3](https://github.com/siomiz/PostgreSQL-S3), this image has the necessary utilties for you to perform continuous postgres backups to S3.
The idea is here is to provide an easy ready-to-go way to dump an entire postgresql database, compress it, encrypt it, and push it to Amazon s3.

> Please check the version/tag you pull of this image. If a version mismatch
> occurs, pg_dumpall will not execute!

##### Features:

* Symmetric Encryption via gpg
* Compression via xz (lzma2)
* Extreme configurability via environment variables :)

#### Up and Running

Without going through and providing all the required env vars, here is a quick docker run line for getting up and running with this container.

```
docker run --link postgres:postgres inanimate/postgres-s3-archive
```

> Note that the alias/name used to identify your linked postgres container must actually be *postgres*!

#### Environment variables

##### *Required*

* `AWS_ACCESS_KEY_ID` - AWS S3 access key.
* `AWS_SECRET_ACCESS_KEY` - AWS S3 secret key.
* `BUCKET` - AWS S3 bucket (and folder) to store the backup. i.e. `s3://herpderpbucket/folder`
* `SYMMETRIC_PASSPHRASE` - The gpg symmetric passphrase to use to encrypt your file.

##### *Optional*

* `PGHOST/PGPORT` - Two variables which can be set to specify the usage of a different container or postgres server (meaning you aren't linking). (default: HOST and PORT of the container you link.)
* `PGUSER` - The database user to connect as (default: `postgres`)

> We assume the user provided has full access without a password needed. Please make sure this exists and your server allows this user to login from the same network segment.

* `TIMEOUT` - How often perform backup, in seconds. (default: `86400`)
* `NAME_PREFIX` - A prefix in front of the date i.e. `jira-data-dir-backup` (default: `database-archive`)
* `GPG_COMPRESSION_LEVEL` - The compression level for gpg to use (0-9). (default: `0`; *not recommended since we're using xz*)
* `XZ_COMPRESSION_LEVEL` - The compression level for xz (lzma2) to use (0-9). (default: `9`; *this is the best compression level*)
* `CIPHER_ALGO` - The cipher for gpg to utilize when encrypting your archive. (default: `aes256`)
* `EXTENSION` - The extension to use for the backup file i.e. `tgz,tar.xz,bz2` (default: `.psql.xz.gpg`)
* `AWSCLI_OPTIONS` - Provide some arguments to awscli (default: `--sse`) See [here](http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html) for possibilities.

> All other [aws-cli](https://github.com/aws/aws-cli) variables are also supported.

#### A few notes

* Use spaces in your buckets, prefix, or extension *at your own risk*!
* I really didn't feel like using cron. Deal with it.
* One day, I'll implement asymmetric encryption so you can use your gpg keys. For now, [this](https://github.com/siomiz/PostgreSQL-S3/blob/master/entrypoint.sh) image does...maybe you could make your own ;P

