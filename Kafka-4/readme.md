
**KAFKA 4.2.0 ON OL8.10**

> *Apache Kafka 4.2.0, released in February 2026, is an update focused on operational stability, performance, and improvements to KRaft, consolidating features such as Share Groups (traditional queue-style message queues) and enhancing resilience in Kafka Streams with native dead letter queues..*

![oracle database 26ai logo.](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/Oracle_AI_Database_26ai/images/oracle_ai_database_26ai_logo.png)

###### INSTALL JAVA 17 OPEN JDK

    [root@ol8kfk ~]# dnf install java-17-openjdk-devel -y
    [root@ol8kfk ~]# java -version
      openjdk version "17.0.18" 2026-01-20 LTS
      OpenJDK Runtime Environment (Red_Hat-17.0.18.0.8-1.0.1) (build 17.0.18+8-LTS)
      OpenJDK 64-Bit Server VM (Red_Hat-17.0.18.0.8-1.0.1) (build 17.0.18+8-LTS, mixed mode, sharing)

###### GET KAFKA 4.2.0 

    [root@ol8kfk ~]# wget https://dlcdn.apache.org/kafka/4.2.0/kafka_2.13-4.2.0.tgz

###### DECOMPRESS KAFKA 4.2.0 

    [root@ol8kfk ~]# tar -xzvf kafka_2.13-4.2.0.tgz

###### NAVIGATE TO KAFKA 4.2.0 DIRECTORY
    
    [root@ol8kfk ~]# cd kafka_2.13-4.2.0

###### GENERATE A CLUSTER UUID
    
    [root@ol8kfk ~]# KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"

###### FORMAT LOG DIRECTORIES

    [root@ol8kfk ~]# bin/kafka-storage.sh format --standalone -t $KAFKA_CLUSTER_ID -c config/server.properties

###### START THE KAFKA SERVER

    [root@ol8kfk ~]# bin/kafka-server-start.sh config/server.properties

###### CREATE A TOPIC TO STORE YOUR EVENTS

    [root@ol8kfk ~]# bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
    [root@ol8kfk ~]# bin/kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092

###### WRITE SOME EVENTS INTO THE TOPIC

    [root@ol8kfk ~]# bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092

###### READ THE EVENTS
    
    [root@ol8kfk ~]# bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092

###### TERMINATE THE KAFKA ENVIRONMENT

bin/kafka-server-stop.sh
