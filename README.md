# solr-backup-restore
Script to backup and restore solr to s3


Requires the following: 

Solr cloud running with the S3 BackupRepository Plugin installed min Solr v8.10 or above.

```

...solrconfig.xml

<backup>
    <repository name="s3" class="org.apache.solr.s3.S3BackupRepository" default="false">
      <str name="s3.bucket.name">${solr.jdbc.s3.bucket}</str>
      <str name="s3.region">us-east-1</str>
      <str name="aws.accessKeyId">${aws.accessKeyId}</str>
      <str name="aws.secretAccessKey">${aws.secretAccessKey}</str>
      <str name="location">s3:/</str>
    </repository>
  </backup>

```


S3 bucket with correct permissions enabled for the key id and secret access key abobve



Zookeeper installed with the following params passed on startup 

```
bin/solr start -z $ZOO_SERVERS -noprompt -f -m $SOLR_JVM_LIMIT -Dsolr.jdbc.user=$JDBC_USER -Dsolr.jdbc.url=$JDBC_URL -Dsolr.jdbc.pass=$JDBC_PASS -Dsolr.jdbc.isprod=$JDBC_IS_PROD -Daws.accessKeyId=$S3_AWS_KEY_SOLR -Daws.secretAccessKey=$S3_AWS_SECRET_SOLR -Dsolr.jdbc.s3.bucket=$S3_SOLR_BACKUP_BACKUP


```
