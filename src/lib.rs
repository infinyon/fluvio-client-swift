use fluvio::{
    Fluvio as FluvioNative,
    TopicProducer as TopicProducerNative, FluvioConfig, config::{TlsPolicy, TlsConfig, TlsCerts},
};
use fluvio_future::{
    task::run_block_on,
};
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
        ) ;
        pub fn flush(
            self: &TopicProducer
        ) ;
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
