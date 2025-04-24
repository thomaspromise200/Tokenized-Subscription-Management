;; Usage Tracking Contract
;; Monitors consumption of services

(define-data-var admin principal tx-sender)

;; Map to store usage data
(define-map usage-records
  { subscriber: principal, provider: principal, period-start: uint }
  {
    usage-amount: uint,
    last-updated: uint
  }
)

;; Record usage (only provider can do this)
(define-public (record-usage
    (subscriber principal)
    (period-start uint)
    (usage-amount uint))
  (let (
    (key { subscriber: subscriber, provider: tx-sender, period-start: period-start })
    (existing-record (map-get? usage-records key))
  )
    (if (is-some existing-record)
      (let ((current-record (unwrap-panic existing-record)))
        (ok (map-set usage-records key
          {
            usage-amount: (+ (get usage-amount current-record) usage-amount),
            last-updated: block-height
          }
        ))
      )
      (ok (map-set usage-records key
        {
          usage-amount: usage-amount,
          last-updated: block-height
        }
      ))
    )
  )
)

;; Get usage for a specific period
(define-read-only (get-usage (subscriber principal) (provider principal) (period-start uint))
  (map-get? usage-records { subscriber: subscriber, provider: provider, period-start: period-start })
)

;; Admin can correct usage records
(define-public (correct-usage
    (subscriber principal)
    (provider principal)
    (period-start uint)
    (usage-amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (map-set usage-records
      { subscriber: subscriber, provider: provider, period-start: period-start }
      {
        usage-amount: usage-amount,
        last-updated: block-height
      }
    ))
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
