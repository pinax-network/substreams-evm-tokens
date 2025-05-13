use substreams::scalar::BigInt;

// Aave
// https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/tokenization/base/ScaledBalanceTokenBase.sol

/// Compute the actual token balance from a scaled balance and the liquidity index.
/// Both `scaled_balance` and `liquidity_index` are in RAY precision (1e27).
pub fn compute_balance(scaled_balance: BigInt, liquidity_index: BigInt) -> BigInt {
    // RAY = 10^27
    let ray = BigInt::from(10).pow(27);
    scaled_balance * liquidity_index / ray
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::str::FromStr;

    #[test]
    fn test_zero_balance() {
        let scaled_balance = BigInt::zero();
        let liquidity_index = BigInt::from(10).pow(27); // e.g., 1.0 in RAY
        let expected = BigInt::zero();

        let actual = compute_balance(scaled_balance, liquidity_index);
        assert_eq!(
            actual, expected,
            "Balance should be zero when scaled balance is zero"
        );
    }

    #[test]
    fn test_base_liquidity_index() {
        // scaled_balance = 100
        // liquidity_index = 1.0 * 10^27
        // => actual_balance should be 100
        let scaled_balance = BigInt::from(100u64);
        let liquidity_index = BigInt::from(10).pow(27); // exactly 1.0 in RAY
        let expected = BigInt::from(100u64);

        let actual = compute_balance(scaled_balance, liquidity_index);
        assert_eq!(actual, expected, "Should remain 100 if index = 1.0");
    }

    #[test]
    fn test_simple_interest_case() {
        // scaled_balance = 100
        // liquidity_index = 1.05 * 10^27 => 1050000000000000000000000000
        let scaled_balance = BigInt::from(100u64);
        let liquidity_index = BigInt::from_str("1050000000000000000000000000").unwrap();
        // expected = 100 * 1.05 = 105
        let expected = BigInt::from(105u64);

        let actual = compute_balance(scaled_balance, liquidity_index);
        assert_eq!(
            actual, expected,
            "Should compute 105 as the updated balance"
        );
    }

    #[test]
    fn test_user1() {
        let scaled_balance = BigInt::from_str("26952969495731").unwrap();
        let liquidity_index = BigInt::from_str("1114664562587843135811849046").unwrap();
        let expected = BigInt::from_str("30043519953402").unwrap();

        let actual = compute_balance(scaled_balance, liquidity_index);
        assert_eq!(actual, expected);
    }

    #[test]
    fn test_large_values() {
        let scaled_balance = BigInt::from_str("123456789000000000000000000").unwrap();
        let liquidity_index = BigInt::from_str("1000000123456789012345678900").unwrap();
        let expected1 =
            BigInt::from_str("123456804241578751714678875019052100000000000000000000").unwrap();
        assert_eq!(
            &scaled_balance * &liquidity_index,
            expected1,
            "Should match multiply result"
        );

        let actual = compute_balance(scaled_balance, liquidity_index);
        let expected2 = BigInt::from_str("123456804241578751714678875").unwrap();
        assert_eq!(
            actual, expected2,
            "Should match the manually computed big integer result"
        );
    }
}
