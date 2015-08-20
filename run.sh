#!/bin/bash -e

: ${POSTGRES_PORT_5432_TCP_ADDR:?"--link to a PostgreSQL container is not set"}
: ${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID not specified"}
: ${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY not specified"}
: ${BUCKET:?"BUCKET not specified"}
: ${SYMMETRIC_PASSPHRASE:?"SYMMETRIC_PASSPHRASE not specified"}

TIMEOUT=${TIMEOUT:-86400}
XZ_COMPRESSION_LEVEL=${XZ_COMPRESSION_LEVEL:-9}
CIPHER_ALGO=${CIPHER_ALGO:-aes256}
GPG_COMPRESSION_LEVEL=${GPG_COMPRESSION_LEVEL:-0}
NAME_PREFIX=${NAME_PREFIX:-database-archive}
EXTENSION=${EXTENSION:-.psql.xz.gpg}
AWSCLI_OPTIONS=${AWSCLI_OPTIONS:---sse}

backup_and_stream_to_s3() {

while true
  do
    BACKUP="${NAME_PREFIX}_`date +"%Y-%m-%d_%H-%M"`${EXTENSION}"
    echo "Set backup file name to: $BACKUP"
    echo "Starting database backup.."
    pg_dumpall -h "$POSTGRES_PORT_5432_TCP_ADDR" -U postgres | xz -${XZ_COMPRESSION_LEVEL} -zf - | gpg -c --cipher-algo ${CIPHER_ALGO} -z ${GPG_COMPRESSION_LEVEL} --passphrase "${SYMMETRIC_PASSPHRASE}" | aws s3 cp - "${BUCKET}/${BACKUP}" "${AWSCLI_OPTIONS}"
    echo "Backup finished! Sleeping ${TIMEOUT}s"
    sleep $TIMEOUT
  done

}

wait