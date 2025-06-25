;; ------------------------------------------------------
;; Contract: trustchain-did
;; Purpose: Decentralized Identity (DID) verifier with on-chain claims and attestations
;; Author: [Your Name]
;; License: MIT
;; ------------------------------------------------------

(define-constant ERR_CLAIM_EXISTS (err u100))
(define-constant ERR_CLAIM_NOT_FOUND (err u101))
(define-constant ERR_ATTESTATION_EXISTS (err u102))
(define-constant ERR_ATTESTATION_NOT_FOUND (err u103))

;; Data definitions

;; Map claim key (owner, claim-id) to claim details
(define-map claims
  (tuple (owner principal) (claim-id uint))
  (tuple
    (claim-hash (buff 100))    ;; hashed claim data (e.g. IPFS hash)
    (timestamp uint)           ;; block height when claim was registered
    (attestation-count uint)   ;; number of attestations
  )
)

;; Map attestations keyed by (claim key, attester)
(define-map attestations
  (tuple (owner principal) (claim-id uint) (attester principal))
  bool
)

;; Track next claim id per user
(define-map user-next-claim-id
  principal
  uint
)

;; === Register a new claim ===
(define-public (register-claim (claim-hash (buff 100)))
  (let (
        (owner tx-sender)
        (next-id (default-to u0 (map-get? user-next-claim-id owner)))
       )
    (if (is-some (map-get? claims {owner: owner, claim-id: next-id}))
        ERR_CLAIM_EXISTS
        (begin
          (map-set claims {owner: owner, claim-id: next-id} {
            claim-hash: claim-hash,
            timestamp: stacks-block-height,
            attestation-count: u0
          })
          (map-set user-next-claim-id owner (+ next-id u1))
          (ok next-id)
        )
    )
  )
)

;; === Add attestation to a claim ===
(define-public (add-attestation (owner principal) (claim-id uint))
  (let (
        (attester tx-sender)
       )
    (match (map-get? claims {owner: owner, claim-id: claim-id})
      claim
      (if (is-some (map-get? attestations {owner: owner, claim-id: claim-id, attester: attester}))
          ERR_ATTESTATION_EXISTS
          (begin
            (map-set attestations {owner: owner, claim-id: claim-id, attester: attester} true)
            (map-set claims {owner: owner, claim-id: claim-id} {
              claim-hash: (get claim-hash claim),
              timestamp: (get timestamp claim),
              attestation-count: (+ (get attestation-count claim) u1)
            })
            (ok true)
          )
      )
      ERR_CLAIM_NOT_FOUND
    )
  )
)

;; === Remove attestation from a claim ===
(define-public (remove-attestation (owner principal) (claim-id uint))
  (let (
        (attester tx-sender)
       )
    (match (map-get? claims {owner: owner, claim-id: claim-id})
      claim
      (if (is-none (map-get? attestations {owner: owner, claim-id: claim-id, attester: attester}))
          ERR_ATTESTATION_NOT_FOUND
          (begin
            (map-delete attestations {owner: owner, claim-id: claim-id, attester: attester})
            (map-set claims {owner: owner, claim-id: claim-id} {
              claim-hash: (get claim-hash claim),
              timestamp: (get timestamp claim),
              attestation-count: (- (get attestation-count claim) u1)
            })
            (ok true)
          )
      )
      ERR_CLAIM_NOT_FOUND
    )
  )
)

;; === Read-only function: Get claim details ===
(define-read-only (get-claim (owner principal) (claim-id uint))
  (map-get? claims {owner: owner, claim-id: claim-id})
)

;; === Read-only function: Get attestations for a claim ===
(define-read-only (get-attestation (owner principal) (claim-id uint) (attester principal))
  (map-get? attestations {owner: owner, claim-id: claim-id, attester: attester})
)
