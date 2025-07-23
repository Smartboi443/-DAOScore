;; DAOScore - Decentralized Governance Reputation System
;; A comprehensive reputation and influence tracking system for DAOs on Stacks blockchain

(define-constant contract-admin tx-sender)
(define-constant err-admin-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-reputation (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-member-exists (err u105))
(define-constant err-member-not-found (err u106))
(define-constant err-activity-not-found (err u107))
(define-constant err-proposal-not-found (err u108))
(define-constant err-author-not-found (err u109))
(define-constant err-recipient-not-found (err u110))
(define-constant err-invalid-proposal-id (err u111))
(define-constant err-invalid-operation (err u112))
(define-constant max-proposal-id u1000000)
(define-constant max-impact u1000)

;; Enhanced Data Maps
(define-map governance-profiles 
    principal 
    {
        reputation-score: uint,
        proposal-count: uint,
        vote-count: uint,
        last-activity: uint,
        contribution-count: uint,
        successful-proposals: uint,
        participation-rate: uint,
        peer-endorsements: uint
    }
)

(define-map activity-configs
    {action-type: (string-ascii 24)}
    {
        base-impact: uint,
        multiplier: uint,
        min-threshold: uint
    }
)

(define-map proposal-records
    uint
    {
        author: principal,
        status: (string-ascii 12),
        vote-tally: uint,
        timestamp: uint
    }
)

;; Initialize activity configurations with enhanced parameters
(map-set activity-configs 
    {action-type: "proposal"} 
    {
        base-impact: u10,
        multiplier: u2,
        min-threshold: u5
    }
)
(map-set activity-configs 
    {action-type: "vote"} 
    {
        base-impact: u5,
        multiplier: u1,
        min-threshold: u10
    }
)
(map-set activity-configs 
    {action-type: "contribution"} 
    {
        base-impact: u15,
        multiplier: u3,
        min-threshold: u3
    }
)

;; Input Validation Functions
(define-private (is-valid-proposal-id (proposal-id uint))
    (and 
        (> proposal-id u0)
        (<= proposal-id max-proposal-id)
    )
)

(define-private (is-valid-impact (impact uint))
    (<= impact max-impact)
)

(define-private (is-valid-action-type (action-type (string-ascii 24)))
    (or 
        (is-eq action-type "proposal")
        (is-eq action-type "vote")
        (is-eq action-type "contribution")
    )
)

;; Enhanced Public Functions

(define-public (register-member)
    (begin
        (asserts! (is-none (get-governance-profile tx-sender)) err-member-exists)
        (ok (map-set governance-profiles tx-sender {
            reputation-score: u0,
            proposal-count: u0,
            vote-count: u0,
            last-activity: block-height,
            contribution-count: u0,
            successful-proposals: u0,
            participation-rate: u0,
            peer-endorsements: u0
        }))
    )
)

(define-public (submit-proposal (proposal-id uint))
    (begin
        (asserts! (is-valid-proposal-id proposal-id) err-invalid-proposal-id)
        (let (
            (member-profile (unwrap! (get-governance-profile tx-sender) err-member-not-found))
            (activity-config (unwrap! (map-get? activity-configs {action-type: "proposal"}) err-activity-not-found))
            (new-reputation (calculate-impact-score 
                (get base-impact activity-config) 
                (get multiplier activity-config) 
                (get proposal-count member-profile)
            ))
        )
        (begin
            (asserts! (is-none (map-get? proposal-records proposal-id)) err-invalid-input)
            (map-set proposal-records proposal-id {
                author: tx-sender,
                status: "active",
                vote-tally: u0,
                timestamp: block-height
            })
            (ok (map-set governance-profiles tx-sender (merge member-profile {
                reputation-score: (+ (get reputation-score member-profile) new-reputation),
                proposal-count: (+ (get proposal-count member-profile) u1),
                last-activity: block-height
            })))
        ))
    )
)

(define-public (cast-vote (proposal-id uint))
    (begin
        (asserts! (is-valid-proposal-id proposal-id) err-invalid-proposal-id)
        (let (
            (member-profile (unwrap! (get-governance-profile tx-sender) err-member-not-found))
            (activity-config (unwrap! (map-get? activity-configs {action-type: "vote"}) err-activity-not-found))
            (proposal-data (unwrap! (map-get? proposal-records proposal-id) err-proposal-not-found))
            (new-reputation (calculate-impact-score 
                (get base-impact activity-config) 
                (get multiplier activity-config) 
                (get vote-count member-profile)
            ))
            (new-vote-tally (+ (get vote-tally proposal-data) u1))
        )
        (begin
            (asserts! (is-eq (get status proposal-data) "active") err-invalid-input)
            (map-set proposal-records proposal-id 
                (merge proposal-data {vote-tally: new-vote-tally}))
            (ok (map-set governance-profiles tx-sender (merge member-profile {
                reputation-score: (+ (get reputation-score member-profile) new-reputation),
                vote-count: (+ (get vote-count member-profile) u1),
                participation-rate: (calculate-participation-rate 
                    (+ (get vote-count member-profile) u1) 
                    (get proposal-count member-profile)
                ),
                last-activity: block-height
            })))
        ))
    )
)

(define-public (finalize-proposal (proposal-id uint) (new-status (string-ascii 12)))
    (begin
        (asserts! (is-valid-proposal-id proposal-id) err-invalid-proposal-id)
        (let (
            (proposal-data (unwrap! (map-get? proposal-records proposal-id) err-proposal-not-found))
            (author-profile (unwrap! (get-governance-profile (get author proposal-data)) err-author-not-found))
        )
        (begin
            (asserts! (is-eq tx-sender contract-admin) err-admin-only)
            (asserts! (or (is-eq new-status "passed") (is-eq new-status "failed")) err-invalid-input)
            (if (is-eq new-status "passed")
                (map-set governance-profiles (get author proposal-data) 
                    (merge author-profile {
                        successful-proposals: (+ (get successful-proposals author-profile) u1),
                        reputation-score: (+ (get reputation-score author-profile) u50)
                    })
                )
                true
            )
            (ok (map-set proposal-records proposal-id 
                (merge proposal-data {status: new-status})))
        ))
    )
)

(define-public (endorse-member (member principal))
    (let (
        (recipient-profile (unwrap! (get-governance-profile member) err-recipient-not-found))
    )
    (begin
        (asserts! (not (is-eq tx-sender member)) err-unauthorized)
        (ok (map-set governance-profiles member (merge recipient-profile {
            peer-endorsements: (+ (get peer-endorsements recipient-profile) u1),
            reputation-score: (+ (get reputation-score recipient-profile) u5)
        })))
    ))
)

;; Enhanced Private Functions

(define-private (calculate-impact-score (base uint) (multiplier uint) (activity-count uint))
    (let (
        (engagement-bonus (if (> activity-count u10) u2 u1))
    )
    (* base (* multiplier engagement-bonus))
    )
)

(define-private (calculate-participation-rate (votes uint) (total-proposals uint))
    (if (> total-proposals u0)
        (* (/ votes total-proposals) u100)
        u0
    )
)

(define-private (apply-reputation-decay (initial-score uint) (blocks-elapsed uint))
    (let (
        (decay-rate (/ blocks-elapsed u1000))
        (floor-score (/ initial-score u10))
        (reduced-score (if (> decay-rate u0)
            (/ initial-score decay-rate)
            initial-score))
    )
    (if (< reduced-score floor-score)
        floor-score
        reduced-score)
    )
)

;; Enhanced Read-only Functions

(define-read-only (get-governance-profile (member principal))
    (map-get? governance-profiles member)
)

(define-read-only (get-proposal-data (proposal-id uint))
    (map-get? proposal-records proposal-id)
)

(define-read-only (get-activity-config (action-type (string-ascii 24)))
    (map-get? activity-configs {action-type: action-type})
)

(define-read-only (get-current-reputation (member principal))
    (let (
        (member-profile (unwrap! (get-governance-profile member) err-not-found))
        (blocks-elapsed (- block-height (get last-activity member-profile)))
        (base-reputation (get reputation-score member-profile))
        (activity-bonus (if (> (get participation-rate member-profile) u75) u50 u0))
        (success-bonus (* (get successful-proposals member-profile) u25))
    )
    (ok (+ 
        (+ (apply-reputation-decay base-reputation blocks-elapsed) activity-bonus)
        success-bonus
    )))
)

;; Administrative Functions

(define-public (update-activity-config 
    (action-type (string-ascii 24)) 
    (base-impact uint) 
    (multiplier uint) 
    (min-threshold uint)
)
    (begin
        (asserts! (is-eq tx-sender contract-admin) err-admin-only)
        (asserts! (is-valid-action-type action-type) err-invalid-operation)
        (asserts! (is-valid-impact base-impact) err-invalid-input)
        (asserts! (is-valid-impact multiplier) err-invalid-input)
        (asserts! (is-valid-impact min-threshold) err-invalid-input)
        (ok (map-set activity-configs 
            {action-type: action-type} 
            {
                base-impact: base-impact,
                multiplier: multiplier,
                min-threshold: min-threshold
            }
        ))
    )
)