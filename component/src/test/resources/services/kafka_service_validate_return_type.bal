// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import wso2/kafka;

string topic = "service-validate-return-type-test";

kafka:ConsumerConfig consumerConfigs = {
    bootstrapServers: "localhost:9094",
    groupId: "service-test-validate-return-type-group",
    clientId: "service-validate-return-type-consumer",
    offsetReset: "earliest",
    topics: [topic]
};

listener kafka:Consumer kafkaConsumer = new(consumerConfigs);

kafka:ProducerConfig producerConfigs = {
    bootstrapServers: "localhost:9094",
    clientId: "service-producer",
    acks: "all",
    noRetries: 3
};

kafka:Producer kafkaProducer = new(producerConfigs);

boolean isSuccess = false;

service kafkaTestService on kafkaConsumer {
    resource function onMessage(kafka:Consumer consumer, kafka:ConsumerRecord[] records) returns error? {
        foreach kafka:ConsumerRecord kafkaRecord in records {
            byte[] result = kafkaRecord.value;
            if (result.length() > 0) {
                isSuccess = true;
            } else {
                error e = error("New Error");
                return e;
            }
        }
        return;
    }
}

function funcKafkaGetResultText() returns boolean {
    return isSuccess;
}

function funcKafkaProduce() {
    string msg = "test_string";
    byte[] byteMsg = msg.toByteArray("UTF-8");
    var result = kafkaProducer->send(byteMsg, topic);
}
