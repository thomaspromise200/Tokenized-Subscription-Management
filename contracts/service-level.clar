;; Service Level Contract
;; Records agreed terms and features

(define-data-var admin principal tx-sender)

;; Define service tiers
(define-map service-tiers uint
  {
    name: (string-utf8 50),
    description: (string-utf8 200),
    price-per-period: uint,
    period-length: uint,  ;; in blocks
    features: (list 10 (string-utf8 50))
  }
)

;; Map to store subscriber service agreements
(define-map service-agreements
  { subscriber: principal, provider: principal }
  {
    tier-id: uint,
    start-date: uint,
    end-date: uint,
    auto-renew: bool
  }
)

;; Add a new service tier (only admin can do this)
(define-public (add-service-tier
    (tier-id uint)
    (name (string-utf8 50))
    (description (string-utf8 200))
    (price-per-period uint)
    (period-length uint)
    (features (list 10 (string-utf8 50))))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (map-set service-tiers tier-id
      {
        name: name,
        description: description,
        price-per-period: price-per-period,
        period-length: period-length,
        features: features
      }
    ))
  )
)

;; Subscribe to a service
(define-public (subscribe
    (provider principal)
    (tier-id uint)
    (auto-renew bool))
  (let ((tier-data (unwrap! (map-get? service-tiers tier-id) (err u2))))
    (ok (map-set service-agreements
      { subscriber: tx-sender, provider: provider }
      {
        tier-id: tier-id,
        start-date: block-height,
        end-date: (+ block-height (get period-length tier-data)),
        auto-renew: auto-renew
      }
    ))
  )
)

;; Cancel subscription
(define-public (cancel-subscription (provider principal))
  (let ((agreement (unwrap! (map-get? service-agreements { subscriber: tx-sender, provider: provider }) (err u3))))
    (ok (map-set service-agreements
      { subscriber: tx-sender, provider: provider }
      (merge agreement {
        auto-renew: false
      })
    ))
  )
)

;; Get service tier details
(define-read-only (get-service-tier (tier-id uint))
  (map-get? service-tiers tier-id)
)

;; Get subscription details
(define-read-only (get-subscription-details (subscriber principal) (provider principal))
  (map-get? service-agreements { subscriber: subscriber, provider: provider })
)

;; Check if subscription is active
(define-read-only (is-subscription-active (subscriber principal) (provider principal))
  (match (map-get? service-agreements { subscriber: subscriber, provider: provider })
    agreement (ok (< block-height (get end-date agreement)))
    (err u4)
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
