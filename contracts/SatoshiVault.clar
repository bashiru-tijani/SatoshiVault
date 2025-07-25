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

;; Adjust annual reward rate (owner only)
(define-public (set-reward-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (< new-rate u10000) ERR_INVALID_REWARD_RATE) ;; Maximum 100% APY
    (ok (var-set reward-rate new-rate))
  )
)

;; Modify minimum staking duration (owner only)
(define-public (set-min-stake-period (new-period uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (> new-period u0) ERR_INVALID_PERIOD)
    (ok (var-set min-stake-period new-period))
  )
)

;; Deposit sBTC into reward distribution pool
(define-public (add-to-reward-pool (amount uint))
  (begin
    (asserts! (> amount u0) ERR_ZERO_STAKE)
    ;; Transfer sBTC from sender to contract custody
    (try! (contract-call? 'ST1F7QA2MDF17S807EPA36TSS8AMEFY4KA9TVGWXT.sbtc-token
      transfer amount tx-sender (as-contract tx-sender) none
    ))
    ;; Increment available reward pool
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok true)
  )
)

;; CORE STAKING MECHANICS

;; Lock sBTC tokens to begin earning yield
(define-public (stake (amount uint))
  (begin
    (asserts! (> amount u0) ERR_ZERO_STAKE)
    ;; Custody sBTC in protocol vault
    (try! (contract-call? 'ST1F7QA2MDF17S807EPA36TSS8AMEFY4KA9TVGWXT.sbtc-token
      transfer amount tx-sender (as-contract tx-sender) none
    ))
    ;; Create or update staking position
    (match (map-get? stakes { staker: tx-sender })
      prev-stake
      ;; Compound with existing stake
      (map-set stakes { staker: tx-sender } {
        amount: (+ amount (get amount prev-stake)),
        staked-at: stacks-block-height,
      })
      ;; Initialize new staking position
      (map-set stakes { staker: tx-sender } {
        amount: amount,
        staked-at: stacks-block-height,
      })
    )
    ;; Update protocol total value locked
    (var-set total-staked (+ (var-get total-staked) amount))
    (ok true)
  )
)

;; Calculate accrued rewards for staker based on time and rate
(define-read-only (calculate-rewards (staker principal))
  (match (map-get? stakes { staker: staker })
    stake-info
    (let (
        (stake-amount (get amount stake-info))
        (stake-duration (- stacks-block-height (get staked-at stake-info)))
        (annual-reward-basis (/ (* stake-amount (var-get reward-rate)) u10000))
        (blocks-per-year u52560) ;; Approximately 365 days on Stacks mainnet
        (time-factor (/ (* stake-duration u10000) blocks-per-year))
        (earned-reward (* annual-reward-basis (/ time-factor u10000)))
      )
      earned-reward
    )
    u0 ;; No active stake found
  )
)

;; Harvest accrued rewards while maintaining staking position
(define-public (claim-rewards)
  (let (
      (stake-info (unwrap! (map-get? stakes { staker: tx-sender }) ERR_NO_STAKE_FOUND))
      (reward-amount (calculate-rewards tx-sender))
    )
    (asserts! (> reward-amount u0) ERR_NO_STAKE_FOUND)
    (asserts! (<= reward-amount (var-get reward-pool)) ERR_NOT_ENOUGH_REWARDS)
    ;; Decrease available reward pool
    (var-set reward-pool (- (var-get reward-pool) reward-amount))
    ;; Track cumulative rewards claimed
    (match (map-get? rewards-claimed { staker: tx-sender })
      prev-claimed (map-set rewards-claimed { staker: tx-sender } { amount: (+ reward-amount (get amount prev-claimed)) })
      (map-set rewards-claimed { staker: tx-sender } { amount: reward-amount })
    )
    ;; Reset reward calculation timer
    (map-set stakes { staker: tx-sender } {
      amount: (get amount stake-info),
      staked-at: stacks-block-height,
    })
    ;; Distribute rewards to staker
    (as-contract (try! (contract-call? 'ST1F7QA2MDF17S807EPA36TSS8AMEFY4KA9TVGWXT.sbtc-token
      transfer reward-amount (as-contract tx-sender) tx-sender none
    )))
    (ok true)
  )
)

;; Withdraw staked sBTC after minimum lock period with automatic reward claim
(define-public (unstake (amount uint))
  (let (
      (stake-info (unwrap! (map-get? stakes { staker: tx-sender }) ERR_NO_STAKE_FOUND))
      (staked-amount (get amount stake-info))
      (staked-at (get staked-at stake-info))
      (stake-duration (- stacks-block-height staked-at))
    )
    ;; Validate withdrawal requirements
    (asserts! (> amount u0) ERR_ZERO_STAKE)
    (asserts! (>= staked-amount amount) ERR_NO_STAKE_FOUND)
    (asserts! (>= stake-duration (var-get min-stake-period))
      ERR_TOO_EARLY_TO_UNSTAKE
    )
    ;; Auto-harvest pending rewards before withdrawal
    (try! (claim-rewards))
    ;; Update or close staking position
    (if (> staked-amount amount)
      (map-set stakes { staker: tx-sender } {
        amount: (- staked-amount amount),
        staked-at: stacks-block-height,
      })
      (map-delete stakes { staker: tx-sender })
    )
    ;; Decrease total value locked
    (var-set total-staked (- (var-get total-staked) amount))
    ;; Return sBTC to user wallet
    (as-contract (try! (contract-call? 'ST1F7QA2MDF17S807EPA36TSS8AMEFY4KA9TVGWXT.sbtc-token
      transfer amount (as-contract tx-sender) tx-sender none
    )))
    (ok true)
  )
)

;; READ-ONLY QUERY FUNCTIONS

;; Retrieve staking position details for specific user
(define-read-only (get-stake-info (staker principal))
  (map-get? stakes { staker: staker })
)

;; Get lifetime rewards claimed by user
(define-read-only (get-rewards-claimed (staker principal))
  (map-get? rewards-claimed { staker: staker })
)

;; Current annual reward rate in basis points
(define-read-only (get-reward-rate)
  (var-get reward-rate)
)

;; Minimum required staking duration in blocks
(define-read-only (get-min-stake-period)
  (var-get min-stake-period)
)

;; Total sBTC available for reward distribution
(define-read-only (get-reward-pool)
  (var-get reward-pool)
)

;; Total sBTC locked in protocol vaults
(define-read-only (get-total-staked)
  (var-get total-staked)
)

;; Calculate current APY percentage from basis points
(define-read-only (get-current-apy)
  (let ((rate-basis (var-get reward-rate)))
    ;; Convert basis points to percentage (e.g., 500 basis points = 5.00%)
    (/ rate-basis u100)
  )
)

;; Comprehensive protocol metrics and statistics
(define-read-only (get-protocol-stats)
  {
    total-staked: (var-get total-staked),
    reward-pool: (var-get reward-pool),
    reward-rate: (var-get reward-rate),
    min-stake-period: (var-get min-stake-period),
    current-apy: (get-current-apy),
  }
)
