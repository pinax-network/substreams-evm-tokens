# EVM Tokens: `ERC20 Allowances`

> Substreams for tracking ERC-20 allowances for EVM blockchains.

## Methodology

To reconstruct ERC‑20 allowances off‑chain, stream the token’s `Approval` and `Transfer` logs in strict block order from its deployment block onward, updating an `(owner → spender)` state table as you go: each `Approval` event overwrites the stored allowance for that pair, while every `transferFrom` call—identified by the `Transfer` log plus the transaction’s function selector—subtracts the transferred amount from the spender’s allowance unless the prior value is `2²⁵⁶ − 1` (treated as infinite). Treat `Approval`‑emitting extensions like `permit` or `increaseAllowance` exactly the same, because they still produce the canonical `Approval` event.

| Function / Event | Purpose | Key rules in the ERC‑20 standard |
|------------------|---------|----------------------------------|
| `approve(spender, value)` | Sets the allowance: `_allowances[msg.sender][spender] = value`. | A later call **overwrites** the previous value (not additive). |
| `transferFrom(from, to, value)` | Moves `value` tokens from `from` to `to`. | Must decrease `_allowances[from][msg.sender]` by `value` **unless** the allowance is `2²⁵⁶ − 1` (treated as “infinite”). |
| `allowance(owner, spender)` | View‑only function returning the current allowance. | Pure getter—no state change. |
| `Approval(owner, spender, value)` | Emitted on every successful `approve`. | **Required** event; shows the *new* allowance value. |
| `Transfer(from, to, value)` | Emitted by both `transfer` and `transferFrom`. | Required for all token moves; does **not** itself prove an allowance change. |

## Edge cases

- `approve(0)` followed by `approve(n)` is common UI pattern.
- Infinite approvals: treat `2**256‑1` as sentinel “∞” so you don’t subtract.
- Revoked approvals: just set to `0` on the next `Approval`.
