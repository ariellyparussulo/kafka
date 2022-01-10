const { Kafka, logLevel } = require('kafkajs');
const Bunyan = require('bunyan');

const log = Bunyan.createLogger({
  name: 'consumer',
  level: Bunyan.DEBUG,
});

const brokers = process.env.BROKERS_URL.split(',');
const clientId = process.env.CLIENT_ID;
const groupId = process.env.GROUP_ID;
const topicName = process.env.TOPIC;

const kafka = new Kafka({
  clientId,
  brokers,
  logLevel: logLevel.INFO,
});

const consumer = kafka.consumer({ groupId });

const main = async () => {
  log.info('Connecting with kafka cluster...');
  await consumer.connect();

  log.info(`Subscribing to ${topicName}...`);
  await consumer.subscribe({
    topic: topicName,
    fromBeginning: true,
  });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const prefix = `${topic}[${partition} | ${message.offset}] / ${message.timestamp}`;
      log.info(`- ${prefix} ${message.key}#${message.value}`);
    },
  });
};

main();
