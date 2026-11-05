# Inventory lot costing — future work

Implemented in the current stage (see code):

- **1 lot ↔ 1 goods-receipt (shipment) line** for purchase stock.
- **Batch number / mfg / expiry** denormalized on the lot (batch = UI group of lots).
- **Line planned unit cost** from line discount + allocated order-level discount.
- **Inbound freight / duty** on a receipt allocated into lot `effectiveCost` (landed).
- **`effectiveCost` frozen** on purchase lots after create.
- **Manual lot cost change**: if `consumed > 0`, auto-split remaining into a new lot (`total` capped to `consumed` on the old lot).
- **`order_items.receivedQuantity`** for partial receives.
- **`product_batches.shipmentLineUuid`** (null when `isManual`); **`sourceLotUuid`** after cost split.
- **Product details** screen (`ProductDetailsScreen`): hero + on-hand / open-lots / inventory value; lot list with Open/All/Consumed filters; group by `batchNumber`; manual-lot sheet; purchase lot → PO # / supplier / received date + deep link to order detail; list tap opens details (edit from app bar).

## Deferred (not in this stage)

### Product details — remaining Phase C (polish / lineage)

Done already on the details screen: inventory value (Σ remaining × `effectiveCost`), Open/All/Consumed chips, lots ordered FEFO via `watchBatchesForProduct` (expiry then `createdAt`).

Still to do later:

- **Expiry-soon filter**
  - Chip or segment alongside Open / All / Consumed (e.g. “Expiring” within N days; reuse same threshold as `watchExpiringSoonBatches`, default 60).
  - Highlight / sort those lots first; keep warning accent on expiry already used on cards.
- **Cost-split lineage (`sourceLotUuid`)**
  - When a manual cost change splits a lot, show “Split from …” on the new lot (batch # / short id / unit cost of parent).
  - Optional: tap parent to scroll/focus that lot, or a small lineage sheet (parent → children).
  - Do **not** allow editing purchase-lot cost from this UI; lineage is read-only context for manual splits only.
- **Consumed section UX**
  - Optional collapsible “Fully consumed” block when filter is All (instead of mixing open + empty in one flat list).
  - Keep default filter = Open so day-to-day stock stays uncluttered.
- **Batch-group summary row**
  - Under each `batchNumber` header: sum remaining qty + inventory value for lots in that group (handy when one label spans many shipment lots).

### Product details — Phase D (catalogs & outbound history)

Depends on catalogs existing as sellable pools (not product master prices).

- **Catalog memberships**
  - Section on product details: which catalogs include this product / which of its lots are pooled.
  - Per membership: catalog name, sell price(s), consume strategy (FEFO / FIFO / short-expiry pool), link to catalog screen.
  - Empty state: “Not in any catalog yet” + CTA once catalog create/edit exists.
- **Sales-out / consumption history**
  - Per lot (or product): which sale orders / return lines consumed qty (from FEFO allocations / order items with `batchUuid`).
  - Show date, order #, qty, customer; deep link to sale order detail.
  - Helps 360° view beyond inbound PO/receipt (Phase B already covers inbound).
- **Do not** put retail/wholesale or “add to sale” CTAs on product details until catalogs own selling; product remains inventory identity + lots.

### Product master vs catalogs vs lots
- **Add/Edit Product** stays identity-only (name, SKU, unit, category, service, min-stock alert).
- **Sell prices** live on **catalogs** (virtual pools): a catalog groups selected lots (or product+strategy) with its own prices and its own consume policy (FEFO / FIFO / short-expiry pool vs normal), separate from other catalogs’ lots.
- Same physical product can appear in multiple catalogs at different prices; consumption for a sale uses that catalog’s lot subset + strategy — not the global product FEFO pool alone.

### Partial-receive UI
- Dedicated “Receive shipment” screen: pick qty per open PO line, batch/expiry per line, multiple receipts against one PO.
- Today: creating a purchase as delivered / “Mark delivered” receives **all remaining** qty in one shipment (freight/duty optional).

### Lot hold / exclude from FEFO
- Flag so a lot is not consumed while cost or QC is pending.
- Adjustment qty alone does not quarantine a lot.

### Recoverable tax (VAT / GST input credit)
- Do **not** land recoverable tax into `effectiveCost`.
- Future: tax fields on PO/receipt + tax control / input-credit ledger; settlement separately.
- `orders.taxAmount` remains invoice/payable facing for now, not inventory cost.

### Outbound freight
- Customer delivery cost → expense (or customer charge), never lot cost.

### Discount vouchers as first-class entities
- Voucher master, stacking rules, vendor promotions.
- Until then, vouchers roll into `orders.discountAmount` and allocate like any header discount.

### Purchase-lot cost correction workflow
- Reverse receive + re-receive (or credit note) instead of editing purchase `effectiveCost`.
- UI for that correction path.

### Sync / cloud
- Register `goods_receipts` and `goods_receipt_lines` in sync engine table maps once cloud sync covers inventory.

### Reporting
- Landed-cost vs invoice-cost reports; batch group views (sum lots by `batchNumber`); COGS by lot.

### Strict unique constraint
- DB unique index on `product_batches.shipment_line_uuid` where not null (enforce 1:1 in SQLite).
