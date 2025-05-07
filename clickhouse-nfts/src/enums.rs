use std::fmt;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TransferType {
    Single,
    Batch,
}

impl fmt::Display for TransferType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TransferType::Single => write!(f, "Single"),
            TransferType::Batch => write!(f, "Batch"),
        }
    }
}

/// --- TokenStandard --------------------------------------------------------
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TokenStandard {
    ERC721,
    ERC1155,
}

impl fmt::Display for TokenStandard {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TokenStandard::ERC721 => write!(f, "ERC721"),
            TokenStandard::ERC1155 => write!(f, "ERC1155"),
        }
    }
}
