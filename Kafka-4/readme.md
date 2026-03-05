wget https://dlcdn.apache.org/kafka/4.2.0/kafka_2.13-4.2.0.tgz
ls -ltrha
tar -xfz kafka_2.13-4.2.0.tgz
tar -xzvf kafka_2.13-4.2.0.tgz
clear
ls -ltrha
cd kafka_2.13-4.2.0
clear
ls -ltrh
cd bin/
clear
KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
cd ..
KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
dnf install java-17-openjdk-devel -y
yum install java-17-openjdk-devel -y --disablerepo=pgdg13
java -version
clear
KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
echo $KAFKA_CLUSTER_ID
bin/kafka-storage.sh format --standalone -t $KAFKA_CLUSTER_ID -c config/server.properties
bin/kafka-server-start.sh config/server.properties
exit
clear
cd kafka_2.13-4.2.0
bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
bin/kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092
bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092
bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
bin/kafka-server-stop.sh
