# KSQL test app for international space station location data

This test deployment runs a few applications on cf-for-k8s to demonstrate a
cf-pushed KSQL server running Kafka Streams.

It is tested on Kind, but should also run on other k8s clusters.

## Steps to install:

1. Install cf-for-k8s

2. Install zookeeper, kafka, and a kafka k8s service by appling the yml files in
   this directory.  Note that the kafka-service doesn't include a NodePort or
   LoadBalancer, so kafka will only be available on the k8s internal network at
   `kafka-service.default:9092`
   Note also that the kafka broker is pre-populated with a topic called
   iss-location in order to work with this sample. If you want more topics you
   can fiddle the yaml before deploying, or add them later with kafkacat.

3. `cd ksql-server && cf push`

4. Launch the producer application that fetches the iss location payload and
   publishes it to the `iss-location` topic every 30 seconds:
   `cf push test-producer -o cfpersi/kafka-iss-producer -u process`

   Note: We need to push the app with a `process` health check because it is
   just a simple bash script that runs in a loop and doesn't listen on any port,
   so a `port` check would fail.

5. Start up th ksql cli.  When running on Kind, since we need to reach the ksql
   server through cf routing on localhost:80, we have to use the cloudfoundry 
   dns name, but use the `--net=host` option so that the container shares the
   localhost network adapter: 
   `docker run --net=host -it confluentinc/cp-ksql-cli http://ksql-server.vcap.me:80`

6. In ksql, create a KSQL stream that parses the topic we just produced: 
   `create stream loc_stream (timestamp BIGINT, message VARCHAR, iss_position
   STRUCT<latitude VARCHAR, longitude VARCHAR>) with
   (KAFKA_TOPIC='iss-location', VALUE_FORMAT='JSON');`

7. To prove that it works, query the stream:
   `select * from loc_stream emit changes`
   You should see messages every 30 seconds.

