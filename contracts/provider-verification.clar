;; Provider Verification Contract
;; Validates legitimate service companies

(define-data-var admin principal tx-sender)

;; Map to store verified providers
(define-map verified-providers principal
  {
    name: (string-utf8 100),
    verified: bool,
    verification-date: uint
  }
)

;; Add a new provider (only admin can do this)
(define-public (register-provider (provider-principal principal) (provider-name (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (map-set verified-providers provider-principal
      {
        name: provider-name,
        verified: false,
        verification-date: u0
      }
    ))
  )
)

;; Verify a provider (only admin can do this)
(define-public (verify-provider (provider-principal principal))
  (let ((provider-data (unwrap! (map-get? verified-providers provider-principal) (err u2))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (map-set verified-providers provider-principal
      (merge provider-data {
        verified: true,
        verification-date: block-height
      })
    ))
  )
)

;; Check if a provider is verified
(define-read-only (is-verified-provider (provider-principal principal))
  (match (map-get? verified-providers provider-principal)
    provider-data (ok (get verified provider-data))
    (err u3)
  )
)

;; Get provider details
(define-read-only (get-provider-details (provider-principal principal))
  (map-get? verified-providers provider-principal)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
