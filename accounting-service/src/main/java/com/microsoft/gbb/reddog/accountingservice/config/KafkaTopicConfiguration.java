package com.microsoft.gbb.reddog.accountingservice.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaTopicConfiguration {

    @Value("${topic.name.producer}")
    private String topicName;

    @Bean
    public NewTopic ordersTopic() {
        return TopicBuilder.name(topicName)
                .build();
    }
}
