use substreams::scalar::BigInt;
use substreams_abis::evm::token::erc721;

// Returns the token collection symbol.
pub fn get_token_collection_symbol(contract: Vec<u8>) -> Option<String> {
    erc721::functions::Symbol {}.call(contract)
}

// Returns the token collection name.
pub fn get_token_collection_name(contract: Vec<u8>) -> Option<String> {
    erc721::functions::Name {}.call(contract)
}

// Returns the Uniform Resource Identifier (URI) for `tokenId` token.
pub fn get_token_uri(contract: Vec<u8>, token_id: BigInt) -> Option<String> {
    erc721::functions::TokenUri{token_id}.call(contract)
}