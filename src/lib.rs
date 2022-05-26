use fluvio::{
    Fluvio as FluvioNative,
    TopicProducer as TopicProducerNative,
    PartitionConsumer as PartitionConsumerNative,
    Offset as OffsetNative,
    FluvioConfig, config::{TlsPolicy, TlsConfig, TlsCerts},
    consumer::Record,
    dataplane::ErrorCode,
};

use fluvio_future::{
    task::run_block_on,
    io::{
        Stream,
        StreamExt,
    },
};
use std::pin::Pin;

#[swift_bridge::bridge]
mod ffi {
    extern "Rust" {
        type FluvioProfile;

        #[swift_bridge(init)]
        fn new(endpoint: &str, domain: &str, key: &str, cert: &str, ca_cert: &str) -> FluvioProfile;
        fn connect(self: &FluvioProfile) -> Fluvio;

        type Fluvio;
        fn topic_producer(self: &Fluvio, topic: &str) -> TopicProducer;

        type TopicProducer;
        pub fn send(
            self: &TopicProducer,
            key: &[u8],
            value: &[u8],
        );
        pub fn flush(
            self: &TopicProducer
        );

        type PartitionConsumer;
        fn partition_consumer(
            self: &Fluvio,
            topic: &str,
            partition: i32
        ) -> PartitionConsumer;
        type Offset;

        type PartitionConsumerStream;
        fn stream(
            self: &PartitionConsumer,
            offset: Offset,
        ) -> PartitionConsumerStream;
        type Record;
        fn next(self: &mut PartitionConsumerStream) -> Option<Record>;
    }
}

pub struct FluvioProfile {
    endpoint: String,
    certs: TlsCerts
}

impl FluvioProfile {
    pub fn new(endpoint: &str, domain: &str, key: &str, cert: &str, ca_cert: &str) -> FluvioProfile {
        FluvioProfile {
            endpoint: endpoint.to_owned(),
            certs: TlsCerts { domain: domain.to_owned(), key: key.to_owned(), cert: cert.to_owned(), ca_cert: ca_cert.to_owned() }
        }
    }

    fn connect(&self) -> Fluvio {
        let config = FluvioConfig::new(self.endpoint.clone())
            .with_tls(TlsPolicy::Verified(TlsConfig::Inline(self.certs.clone())));
        let fluvio = run_block_on(FluvioNative::connect_with_config(&config)).unwrap();
        Fluvio {
            fluvio
        }
    }
}

pub struct Fluvio {
    fluvio: FluvioNative,
}


impl Fluvio {
    pub fn topic_producer(
        self: &Fluvio,
        topic: &str,
    ) -> TopicProducer {
        TopicProducer::from(run_block_on(self.fluvio.topic_producer(topic)).unwrap())
    }
    pub fn partition_consumer(
        self: &Fluvio,
        topic: &str,
        partition: i32,
    ) -> PartitionConsumer {
        PartitionConsumer::from(run_block_on(self.fluvio.partition_consumer(topic, partition)).unwrap())
    }
}

pub struct TopicProducer {
    producer: TopicProducerNative,
}
impl TopicProducer {
    pub fn send(
        self: &TopicProducer,
        key: &[u8],
        value: &[u8],
    ) {
        run_block_on(self.producer.send(key, value)).map(|_| ()).unwrap()
    }
    pub fn flush(
        self: &TopicProducer,
    ) {
        run_block_on(self.producer.flush()).map(|_| ()).unwrap()
    }
}

impl From<TopicProducerNative> for TopicProducer {
    fn from(producer: TopicProducerNative) -> Self {
        Self {
            producer
        }
    }
}

pub struct PartitionConsumer {
    inner: PartitionConsumerNative
}

impl PartitionConsumer {
    pub fn stream(&self, offset: Offset) -> PartitionConsumerStream {
        PartitionConsumerStream {
            inner: Box::pin(run_block_on(self.inner.stream(offset.into())).unwrap())
        }
    }
}

type PartitionConsumerIteratorInner =
    Pin<Box<dyn Stream<Item = Result<Record, ErrorCode>> + Send>>;

pub struct PartitionConsumerStream {
    pub inner: PartitionConsumerIteratorInner,
}
impl PartitionConsumerStream {
    pub fn next(&mut self) -> Option<Record> {
        run_block_on(self.inner.next()).transpose().unwrap()
    }
}

impl From<PartitionConsumerNative> for PartitionConsumer {
    fn from(inner: PartitionConsumerNative) -> Self {
        Self {
            inner
        }
    }
}

pub struct Offset {
    inner: OffsetNative,
}

impl From<OffsetNative> for Offset {
    fn from(inner: OffsetNative) -> Self {
        Self {
            inner
        }
    }
}
impl Into<OffsetNative> for Offset {
    fn into(self) -> OffsetNative {
        self.inner
    }
}
