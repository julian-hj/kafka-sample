FROM confluentinc/cp-kafkacat

RUN apt update && apt install -y curl

COPY run-it.sh /run-it.sh

CMD ["/run-it.sh"]
