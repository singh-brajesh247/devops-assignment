variable "credential_pgp_keys" {
  description = "Base64-encoded PGP public keys (or keybase: handles) for engine, ci, alice, and bob. Used to encrypt generated credentials."
  type        = map(string)

  validation {
    condition = (
      toset(keys(var.credential_pgp_keys)) == toset(["engine", "ci", "alice", "bob"]) &&
      alltrue([for key in values(var.credential_pgp_keys) : trimspace(key) != ""])
    )
    error_message = "Provide a nonempty public PGP key for exactly engine, ci, alice, and bob."
  }
}
