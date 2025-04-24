;; Subscriber Identity Contract
;; Manages customer profiles

(define-data-var admin principal tx-sender)

;; Map to store subscriber profiles
(define-map subscribers principal
  {
    name: (string-utf8 100),
    email: (string-utf8 100),
    active: bool,
    join-date: uint
  }
)

;; Register a new subscriber (self-registration)
(define-public (register-subscriber (name (string-utf8 100)) (email (string-utf8 100)))
  (begin
    (asserts! (is-none (map-get? subscribers tx-sender)) (err u1))
    (ok (map-set subscribers tx-sender
      {
        name: name,
        email: email,
        active: true,
        join-date: block-height
      }
    ))
  )
)

;; Update subscriber profile
(define-public (update-profile (name (string-utf8 100)) (email (string-utf8 100)))
  (let ((subscriber-data (unwrap! (map-get? subscribers tx-sender) (err u2))))
    (ok (map-set subscribers tx-sender
      (merge subscriber-data {
        name: name,
        email: email
      })
    ))
  )
)

;; Deactivate subscriber
(define-public (deactivate-subscriber)
  (let ((subscriber-data (unwrap! (map-get? subscribers tx-sender) (err u2))))
    (ok (map-set subscribers tx-sender
      (merge subscriber-data {
        active: false
      })
    ))
  )
)

;; Admin can deactivate any subscriber
(define-public (admin-deactivate-subscriber (subscriber-principal principal))
  (let ((subscriber-data (unwrap! (map-get? subscribers subscriber-principal) (err u2))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u3))
    (ok (map-set subscribers subscriber-principal
      (merge subscriber-data {
        active: false
      })
    ))
  )
)

;; Get subscriber details
(define-read-only (get-subscriber-details (subscriber-principal principal))
  (map-get? subscribers subscriber-principal)
)

;; Check if subscriber is active
(define-read-only (is-active-subscriber (subscriber-principal principal))
  (match (map-get? subscribers subscriber-principal)
    subscriber-data (ok (get active subscriber-data))
    (err u4)
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u3))
    (ok (var-set admin new-admin))
  )
)
