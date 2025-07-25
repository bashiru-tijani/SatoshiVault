;; SatoshiVault Protocol - Secure sBTC Yield Generation Platform
;;
;; SatoshiVault harnesses the power of Bitcoin's proven security model through
;; Stacks Layer 2 to deliver institutional-grade yield generation for sBTC holders.
;; Built on Bitcoin's immutable foundation, this protocol transforms dormant sBTC
;; into productive assets while maintaining the trustless guarantees that make
;; Bitcoin the world's premier store of value.
;;
;; Key Features:
;; - Bitcoin-Native Security: Inherits Bitcoin's security through Stacks finality
;; - Flexible Staking Periods: Customizable lock-up terms for optimal yield
;; - Dynamic Reward Distribution: Algorithmic reward calculation based on time and pool size
;; - Non-Custodial Design: Users maintain full control of their staked assets
;; - Transparent Governance: On-chain parameter management and fee structure
;;
;; Perfect for Bitcoin maximalists seeking yield without compromising on security
;; or decentralization principles. Every satoshi remains anchored to Bitcoin's
;; unbreakable consensus while generating sustainable returns.

;; ERROR CONSTANTS

(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_ZERO_STAKE (err u101))
(define-constant ERR_NO_STAKE_FOUND (err u102))
(define-constant ERR_TOO_EARLY_TO_UNSTAKE (err u103))
(define-constant ERR_INVALID_REWARD_RATE (err u104))
(define-constant ERR_NOT_ENOUGH_REWARDS (err u105))
(define-constant ERR_INVALID_PERIOD (err u106))
(define-constant ERR_OWNER_UNCHANGED (err u107))

;; DATA STORAGE MAPS

;; Individual staking positions for each user
(define-map stakes
  { staker: principal }
  {
    amount: uint,
    staked-at: uint,
  }
)

;; Historical reward claims tracking per staker
(define-map rewards-claimed
  { staker: principal }
  { amount: uint }
)

;; PROTOCOL CONFIGURATION

;; Annual reward rate in basis points (default: 500 = 5.00% APY)
(define-data-var reward-rate uint u500)

;; Total sBTC allocated for reward distribution
(define-data-var reward-pool uint u0)

;; Minimum lock period in blocks (default: ~14 days on Stacks mainnet)
(define-data-var min-stake-period uint u2016)

;; Total sBTC currently locked in the protocol
(define-data-var total-staked uint u0)

;; Protocol administrator principal
(define-data-var contract-owner principal tx-sender)

;; ADMINISTRATIVE FUNCTIONS

;; Retrieve current protocol owner
(define-read-only (get-contract-owner)
  (var-get contract-owner)
)

;; Transfer protocol ownership to new administrator
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (not (is-eq new-owner (var-get contract-owner)))
      ERR_OWNER_UNCHANGED
    )
    (ok (var-set contract-owner new-owner))
  )
)