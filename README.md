# SatoshiVault Protocol

## 🔐 Secure sBTC Yield Generation Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Clarity Version](https://img.shields.io/badge/Clarity-3.0-blue)](https://docs.stacks.co/clarity)
[![Stacks](https://img.shields.io/badge/Stacks-Layer%202-orange)](https://stacks.co)

SatoshiVault harnesses the power of Bitcoin's proven security model through Stacks Layer 2 to deliver institutional-grade yield generation for sBTC holders. Built on Bitcoin's immutable foundation, this protocol transforms dormant sBTC into productive assets while maintaining the trustless guarantees that make Bitcoin the world's premier store of value.

## 🌟 Key Features

- **🛡️ Bitcoin-Native Security**: Inherits Bitcoin's security through Stacks finality
- **⏰ Flexible Staking Periods**: Customizable lock-up terms for optimal yield (minimum 14 days)
- **📊 Dynamic Reward Distribution**: Algorithmic reward calculation based on time and pool size
- **🔒 Non-Custodial Design**: Users maintain full control of their staked assets
- **🏛️ Transparent Governance**: On-chain parameter management and fee structure
- **📈 Competitive APY**: Default 5% annual percentage yield with owner-adjustable rates

Perfect for Bitcoin maximalists seeking yield without compromising on security or decentralization principles. Every satoshi remains anchored to Bitcoin's unbreakable consensus while generating sustainable returns.

## 🏗️ Architecture

### Core Components

- **Staking Engine**: Secure sBTC custody and position management
- **Reward Calculator**: Time-based yield computation with configurable rates
- **Administration Module**: Owner-controlled parameter adjustment
- **Query Interface**: Comprehensive read-only data access

### Security Model

- Bitcoin-finalized transactions through Stacks consensus
- Non-custodial asset management
- Owner-based access controls for critical functions
- Minimum lock periods to ensure protocol stability

## 📋 Prerequisites

- [Clarinet CLI](https://docs.hiro.so/stacks/clarinet) >= 2.0
- [Node.js](https://nodejs.org/) >= 18.0
- [Git](https://git-scm.com/)

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/bashiru-tijani/SatoshiVault.git
cd SatoshiVault

# Install dependencies
npm install

# Verify Clarinet installation
clarinet --version
```

### Development Setup

```bash
# Check contract syntax and deploy locally
clarinet check

# Run the test suite
npm test

# Run tests with coverage reporting
npm run test:report

# Watch mode for continuous testing
npm run test:watch
```

## 🔧 Contract API

### Core Functions

#### Staking Operations

```clarity
;; Stake sBTC tokens to earn yield
(stake (amount uint))

;; Claim accumulated rewards
(claim-rewards)

;; Withdraw staked tokens (after minimum period)
(unstake (amount uint))
```

#### Administrative Functions

```clarity
;; Set annual reward rate (owner only)
(set-reward-rate (new-rate uint))

;; Adjust minimum staking period (owner only)
(set-min-stake-period (new-period uint))

;; Add tokens to reward pool
(add-to-reward-pool (amount uint))

;; Transfer contract ownership
(set-contract-owner (new-owner principal))
```

### Read-Only Functions

```clarity
;; Get user's staking position
(get-stake-info (staker principal))

;; Calculate pending rewards
(calculate-rewards (staker principal))

;; Get protocol statistics
(get-protocol-stats)

;; Get current APY as percentage
(get-current-apy)
```

## 💰 Economics

### Reward Mechanism

- **Default APY**: 5.00% (500 basis points)
- **Maximum APY**: 100% (configurable by owner)
- **Calculation**: Pro-rata based on stake amount and time
- **Distribution**: On-demand claiming or automatic on unstaking

### Lock Periods

- **Minimum Lock**: 2,016 blocks (~14 days on Stacks mainnet)
- **Reward Accrual**: Continuous from staking timestamp
- **Compounding**: Available through re-staking claimed rewards

### Fee Structure

- **Staking Fee**: None
- **Unstaking Fee**: None
- **Reward Claim Fee**: None

## 🧪 Testing

### Running Tests

```bash
# Run all tests
npm test

# Run specific test file
npx vitest tests/SatoshiVault.test.ts

# Run with detailed output
npm run test:report
```

### Test Coverage

The test suite covers:

- Staking mechanics and validation
- Reward calculation accuracy
- Administrative function security
- Edge cases and error conditions
- Integration with sBTC token contract

## 📊 Usage Examples

### Basic Staking Workflow

```clarity
;; 1. Stake 1000 sBTC (1,000,000 micro-sBTC)
(contract-call? .SatoshiVault stake u1000000)

;; 2. Check your staking position
(contract-call? .SatoshiVault get-stake-info tx-sender)

;; 3. Calculate pending rewards after some time
(contract-call? .SatoshiVault calculate-rewards tx-sender)

;; 4. Claim accumulated rewards
(contract-call? .SatoshiVault claim-rewards)

;; 5. Unstake after minimum period (auto-claims rewards)
(contract-call? .SatoshiVault unstake u500000)
```

### Protocol Administration

```clarity
;; Adjust reward rate to 7.5% APY (owner only)
(contract-call? .SatoshiVault set-reward-rate u750)

;; Extend minimum lock period to 30 days
(contract-call? .SatoshiVault set-min-stake-period u4320)

;; Add 10,000 sBTC to reward pool
(contract-call? .SatoshiVault add-to-reward-pool u10000000)
```

## 🛡️ Security Considerations

### Audits

- [ ] Independent security audit pending
- [ ] Formal verification of reward calculations
- [ ] Stress testing under various market conditions

### Risk Factors

- **Smart Contract Risk**: Inherent risks in any blockchain protocol
- **sBTC Peg Risk**: Dependency on sBTC maintaining Bitcoin parity
- **Stacks Network Risk**: Reliance on Stacks L2 consensus and finality
- **Liquidity Risk**: Minimum lock periods prevent immediate withdrawal

### Best Practices

- Start with small amounts to familiarize yourself with the protocol
- Understand minimum lock periods before staking
- Monitor reward pool levels and protocol health
- Keep private keys secure and use hardware wallets when possible

## 🔄 Protocol States

### Healthy Operation

- Sufficient reward pool balance
- Active staking positions
- Regular reward claims
- Stable APY rates

### Edge Cases

- **Empty Reward Pool**: Claims will fail until pool is replenished
- **Zero Stakers**: Protocol remains functional, awaiting participants
- **Maximum Lock Period**: No upper limit on staking duration

## 📈 Monitoring & Analytics

### Key Metrics

- **Total Value Locked (TVL)**: Sum of all staked sBTC
- **Reward Pool Balance**: Available tokens for distribution  
- **Active Stakers**: Number of participants with positions
- **Average Stake Duration**: Time-weighted staking behavior

### Protocol Health Indicators

```clarity
;; Get comprehensive protocol statistics
(contract-call? .SatoshiVault get-protocol-stats)

;; Monitor individual position
(contract-call? .SatoshiVault get-stake-info 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## 🚧 Roadmap

### Phase 1: Core Protocol ✅

- [x] Basic staking mechanics
- [x] Reward calculation engine
- [x] Administrative controls
- [x] Test suite implementation

### Phase 2: Enhanced Features 🔄

- [ ] Multi-tier staking with bonus rates
- [ ] Governance token integration
- [ ] Emergency pause mechanisms
- [ ] Advanced analytics dashboard

### Phase 3: Ecosystem Integration 📋

- [ ] DeFi protocol partnerships
- [ ] Cross-chain bridging support
- [ ] Institutional custody solutions
- [ ] Mobile application interface

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request
5. Code review and merge

### Code Standards

- Follow Clarity best practices
- Include comprehensive test coverage
- Document all public functions
- Use descriptive variable names
- Add inline comments for complex logic

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
