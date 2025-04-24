use substreams_ethereum::{Event, pb::eth::v2::Log};

#[derive(Debug)]
pub struct NewOwner {
    pub node: Vec<u8>,
    pub label: Vec<u8>,
    pub owner: String,
}

impl Event for NewOwner {
    const NAME: &'static str = "NewOwner";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 3
            && log.topics[0] == hex_to_bytes("ce0457fe73731f824cc8fc65b3abfcb9da4e4aec6f5676b2c1c6d5c9e9d44d33") // keccak256("NewOwner(bytes32,bytes32,address)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match NewOwner event".to_string());
        }

        Ok(Self {
            node: log.topics[1].clone(),
            label: log.topics[2].clone(),
            owner: hex_to_address(&log.data),
        })
    }
}

#[derive(Debug)]
pub struct Transfer {
    pub node: Vec<u8>,
    pub owner: String,
}

impl Event for Transfer {
    const NAME: &'static str = "Transfer";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 2
            && log.topics[0] == hex_to_bytes("d4735d920b0f87494915f556dd9b54c8f309026070caea5c737245152564d266") // keccak256("Transfer(bytes32,address)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match Transfer event".to_string());
        }

        Ok(Self {
            node: log.topics[1].clone(),
            owner: hex_to_address(&log.data),
        })
    }
}

#[derive(Debug)]
pub struct NewResolver {
    pub node: Vec<u8>,
    pub resolver: String,
}

impl Event for NewResolver {
    const NAME: &'static str = "NewResolver";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 2
            && log.topics[0] == hex_to_bytes("335721b01866dc23fbee8b6b2c7b1e14d6f05c28cd35a2c934239f94095602a0") // keccak256("NewResolver(bytes32,address)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match NewResolver event".to_string());
        }

        Ok(Self {
            node: log.topics[1].clone(),
            resolver: hex_to_address(&log.data),
        })
    }
}

#[derive(Debug)]
pub struct NewTTL {
    pub node: Vec<u8>,
    pub ttl: u64,
}

impl Event for NewTTL {
    const NAME: &'static str = "NewTTL";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 2
            && log.topics[0] == hex_to_bytes("1d4f9bbfc9cab89d66e1a1562f2233ccbf1308cb4f63de2ead5787adddb8fa68") // keccak256("NewTTL(bytes32,uint64)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match NewTTL event".to_string());
        }

        Ok(Self {
            node: log.topics[1].clone(),
            ttl: u64::from_str_radix(&hex_to_string(&log.data), 16).unwrap_or(0),
        })
    }
}

#[derive(Debug)]
pub struct AddrChanged {
    pub node: Vec<u8>,
    pub address: String,
}

impl Event for AddrChanged {
    const NAME: &'static str = "AddrChanged";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 2
            && log.topics[0] == hex_to_bytes("52d7d861f09ab3d26239d492e8968629f95e9e318cf0b73bfddc441522a15fd2") // keccak256("AddrChanged(bytes32,address)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match AddrChanged event".to_string());
        }

        Ok(Self {
            node: log.topics[1].clone(),
            address: hex_to_address(&log.data),
        })
    }
}

#[derive(Debug)]
pub struct NameChanged {
    pub node: Vec<u8>,
    pub name: String,
}

impl Event for NameChanged {
    const NAME: &'static str = "NameChanged";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 2
            && log.topics[0] == hex_to_bytes("b7d29e911041e8d9b843369e890bcb72c9388692ba48b65ac54e9569c9d0a7b7") // keccak256("NameChanged(bytes32,string)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match NameChanged event".to_string());
        }

        // The name is ABI-encoded in the data field
        // We need to decode it properly, but for now we'll just return an empty string
        Ok(Self {
            node: log.topics[1].clone(),
            name: String::new(),
        })
    }
}

#[derive(Debug)]
pub struct ReverseClaimed {
    pub addr: String,
    pub node: Vec<u8>,
}

impl Event for ReverseClaimed {
    const NAME: &'static str = "ReverseClaimed";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 3
            && log.topics[0] == hex_to_bytes("d4cf9fd7300f7141d73f06522a7d9a7a1237a1c1f3f4c50f8a2b1a8da9ad4a31") // keccak256("ReverseClaimed(address,bytes32)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match ReverseClaimed event".to_string());
        }

        Ok(Self {
            addr: hex_to_address(&log.topics[1]),
            node: log.topics[2].clone(),
        })
    }
}

#[derive(Debug)]
pub struct ContenthashChanged {
    pub node: Vec<u8>,
    pub hash: Vec<u8>,
}

impl Event for ContenthashChanged {
    const NAME: &'static str = "ContenthashChanged";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 2
            && log.topics[0] == hex_to_bytes("e379c1624ed7e714f6c986a679f7c3ec6f52c9d4d7da8cbacdc342c932694a17") // keccak256("ContenthashChanged(bytes32,bytes)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match ContenthashChanged event".to_string());
        }

        // The hash is ABI-encoded in the data field
        // For now, we'll just return the raw data
        Ok(Self {
            node: log.topics[1].clone(),
            hash: log.data.clone(),
        })
    }
}

#[derive(Debug)]
pub struct TextChanged {
    pub node: Vec<u8>,
    pub key: String,
    pub value: String,
}

impl Event for TextChanged {
    const NAME: &'static str = "TextChanged";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() == 2
            && log.topics[0] == hex_to_bytes("d8c9334b1a9c2f9da342a0a2b32629c1a229b6445dad78947f674b44444a7550") // keccak256("TextChanged(bytes32,string,string)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match TextChanged event".to_string());
        }

        // The key and value are ABI-encoded in the data field
        // For now, we'll just return empty strings
        Ok(Self {
            node: log.topics[1].clone(),
            key: String::new(),
            value: String::new(),
        })
    }
}

#[derive(Debug)]
pub struct NameRegistered {
    pub name: String,
    pub label: Vec<u8>,
    pub owner: String,
    pub cost: u64,
    pub expires: u64,
}

impl Event for NameRegistered {
    const NAME: &'static str = "NameRegistered";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() >= 2
            && log.topics[0] == hex_to_bytes("f4c40a5f0e9a5f33a0dcf869e99c8f207e35d8a13b1e88e8e1c3353e4c6c0180") // keccak256("NameRegistered(string,bytes32,address,uint256,uint256)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match NameRegistered event".to_string());
        }

        // The data is ABI-encoded
        // For now, we'll just return placeholder values
        Ok(Self {
            name: String::new(),
            label: log.topics.get(1).cloned().unwrap_or_default(),
            owner: String::new(),
            cost: 0,
            expires: 0,
        })
    }
}

#[derive(Debug)]
pub struct NameRenewed {
    pub name: String,
    pub label: Vec<u8>,
    pub cost: u64,
    pub expires: u64,
}

impl Event for NameRenewed {
    const NAME: &'static str = "NameRenewed";
    
    fn match_log(log: &Log) -> bool {
        log.topics.len() >= 2
            && log.topics[0] == hex_to_bytes("3da24c024582931cfaf8267d8ed24d13a82a8068d5bd337d30ec45cea4e506ae") // keccak256("NameRenewed(string,bytes32,uint256,uint256)")
    }

    fn decode(log: &Log) -> Result<Self, String> {
        if !Self::match_log(log) {
            return Err("Log doesn't match NameRenewed event".to_string());
        }

        // The data is ABI-encoded
        // For now, we'll just return placeholder values
        Ok(Self {
            name: String::new(),
            label: log.topics.get(1).cloned().unwrap_or_default(),
            cost: 0,
            expires: 0,
        })
    }
}

// Helper functions

fn hex_to_bytes(hex: &str) -> Vec<u8> {
    let hex = hex.trim_start_matches("0x");
    (0..hex.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(&hex[i..i + 2], 16).unwrap_or(0))
        .collect()
}

fn hex_to_string(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{:02x}", b)).collect()
}

fn hex_to_address(bytes: &[u8]) -> String {
    format!("0x{}", hex_to_string(&bytes[bytes.len() - 20..]))
}
