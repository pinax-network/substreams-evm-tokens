#[derive(Clone, Debug, Default)]
pub struct ENSEvents {
    pub name_registered: Vec<NameRegistered>,
    pub name_renewed: Vec<NameRenewed>,
    pub name_transferred: Vec<NameTransferred>,
    pub new_owner: Vec<NewOwner>,
    pub new_resolver: Vec<NewResolver>,
    pub new_ttl: Vec<NewTTL>,
    pub transfer: Vec<Transfer>,
    pub addr_changed: Vec<AddrChanged>,
    pub name_changed: Vec<NameChanged>,
    pub contenthash_changed: Vec<ContenthashChanged>,
    pub text_changed: Vec<TextChanged>,
}

#[derive(Clone, Debug, Default)]
pub struct ENSName {
    pub name: String,
    pub label: String,
    pub node: String,
    pub owner: String,
    pub resolver: String,
    pub ttl: u64,
    pub expiry: u64,
    pub addr: String,
    pub contenthash: String,
    pub text_records: std::collections::HashMap<String, String>,
    pub created_at: u64,
    pub updated_at: u64,
}

#[derive(Clone, Debug, Default)]
pub struct NewOwner {
    pub node: String,
    pub label: String,
    pub owner: String,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct Transfer {
    pub node: String,
    pub owner: String,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct NewResolver {
    pub node: String,
    pub resolver: String,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct NewTTL {
    pub node: String,
    pub ttl: u64,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct NameRegistered {
    pub name: String,
    pub label: String,
    pub owner: String,
    pub cost: u64,
    pub expires: u64,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct NameRenewed {
    pub name: String,
    pub label: String,
    pub cost: u64,
    pub expires: u64,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct NameTransferred {
    pub name: String,
    pub label: String,
    pub owner: String,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct AddrChanged {
    pub node: String,
    pub address: String,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct NameChanged {
    pub node: String,
    pub name: String,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct ContenthashChanged {
    pub node: String,
    pub hash: String,
    pub timestamp: u64,
    pub transaction_hash: String,
}

#[derive(Clone, Debug, Default)]
pub struct TextChanged {
    pub node: String,
    pub key: String,
    pub value: String,
    pub timestamp: u64,
    pub transaction_hash: String,
}