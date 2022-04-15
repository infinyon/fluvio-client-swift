use fluvio::{
    Fluvio as FluvioNative,
    TopicProducer as TopicProducerNative,
};
use fluvio_future::{
    task::run_block_on,
};
#[swift_bridge::bridge]
mod ffi {
    extern "Rust" {
        type Fluvio;

        #[swift_bridge(init)]
        fn connect(profile: &str) -> Fluvio;

        fn topic_producer(self: &Fluvio, topic: &str) -> TopicProducer;
        type TopicProducer;
        pub fn send(
            self: &TopicProducer,
            key: &[u8],
            value: &[u8],
        ) ;
    }
}

pub struct Fluvio {
    fluvio: FluvioNative,
}

impl Fluvio {
    fn connect(profile: &str) -> Self {
        let fluvio = run_block_on(FluvioNative::connect()).unwrap();
        Fluvio {
            fluvio
        }
    }

    pub fn topic_producer(
        self: &Fluvio,
        topic: &str,
    ) -> TopicProducer {
        TopicProducer::from(run_block_on(self.fluvio.topic_producer(topic)).unwrap())
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
}

impl From<TopicProducerNative> for TopicProducer {
    fn from(producer: TopicProducerNative) -> Self {
        Self {
            producer
        }
    }
}
