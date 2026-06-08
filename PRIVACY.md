# Privacy Policy — Phoenix Gate

**Last updated:** June 8, 2026

Phoenix Gate ("the app", "we", "us") is an open-source event access-verification
app published by **Stella Achenbach** (part of The ALANA Project). This policy
explains what the app does and does not do with information. It applies to the iOS
and Android versions of Phoenix Gate.

## Summary

Phoenix Gate is a **read-only verification tool**. It does **not** collect, store,
or transmit personal data to us or to any third-party analytics service. It does
not require an account, a login, or a password. Everything you configure stays on
your device.

## Information the app handles

**1. NFC card data (burner.pro cards)**
When an organizer taps an attendee's burner.pro card, the app reads the public
wallet address and signature data from the card solely to verify on-chain
membership or ticket ownership in real time. This data is processed on-device and
is **not** stored by the app after the verification check, and is **not** sent to
us.

**2. Blockchain queries (public RPC)**
To verify ownership, the app sends the relevant wallet address and the
organizer-provided Unlock Protocol contract address to public blockchain RPC
endpoints (for example, on Ethereum, Polygon, Optimism, Arbitrum One, Base, or
Gnosis) to perform a read-only `balanceOf` lookup. These queries are handled by
third-party public RPC providers under their own terms; the app does not control
or log them. The app only performs read operations — it never signs transactions,
moves funds, or accesses private keys.

**3. Branding and app settings (stored locally)**
Event organizers can customize colors, a logo, and a membership image. These
settings, including any images you select from your photo library, are stored
**locally on your device** using standard on-device storage. They are not uploaded
to us or shared with third parties.

**4. Photo library access**
The app requests access to your photo library only so you can choose a logo or
branding image. Selected images remain on your device.

## Information we do NOT collect

- We do not collect names, emails, or contact information.
- We do not use analytics or tracking SDKs.
- We do not create user profiles or advertising identifiers.
- We do not sell or share any data, because we do not collect any.

## Children's privacy

Phoenix Gate is a business tool for event organizers and is not directed at
children.

## Third-party services

The app communicates with public blockchain RPC endpoints to perform verification
lookups. These are independent services governed by their own privacy practices.
The app does not send personal data to these services beyond the wallet address
and contract address required for a read-only ownership check.

## Changes to this policy

We may update this policy as the app evolves. Material changes will be reflected by
updating the "Last updated" date above and committing the change to this
repository.

## Contact

Questions about this policy can be directed to **Stella Achenbach** (The ALANA
Project).

- Email: contact@stellaachenbach.com
- Project: https://github.com/The-ALANA-Project/PhoenixGate

---

© 2025 The ALANA Project S.A.C. Source code released under the MIT License.
