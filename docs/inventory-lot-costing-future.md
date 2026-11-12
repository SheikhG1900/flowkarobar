# Inventory / stock management — future work

Living backlog for stock, lots, orders, production, and related UX.  
Update this file when items ship or new gaps appear.

---

## Prioritized TODO (do not miss)

### High

- [ ] **Returns create UI** — `OrdersRepository.createReturn` restocks/consumes lots; list tab exists; create flow still “coming soon” (`order_action_sheet`). Wire full sale/purchase return UX from order detail.
- [ ] **Partial goods-receive screen** — Backend supports per-line qty + batch/expiry (`receivedQuantity`, `receivePurchaseShipment`). UI today is mostly “receive all remaining” / mark delivered. Need dedicated receive-shipment flow (multi-receipt per PO).
- [ ] **Sell pricing source (catalogs)** — Catalog Drift tables + sync exist; **no** feature UI/repo. Product form is identity-only; sales still use `product.retailPrice`. Either finish catalogs (pools, prices, consume strategy) or temporarily own prices on product again until catalogs land.
- [ ] **Sale multi-lot lineage** — FEFO can consume across lots; `order_items.batchUuid` keeps only the **first** allocation. Persist full allocations for audit and accurate return-to-lot.
- [ ] **Stock shortfall policy** — Clear block vs allow-overcommit on sale deliver / production complete; consistent UI messaging (preview already exists for production).

### Medium

- [ ] **Expiry / near-expiry UX** — `watchExpiringSoonBatches` + dashboard count exist. Add product-details “Expiring” filter (reuse ~60-day threshold), optional push/notification alongside low-stock.
- [ ] **Stock / inventory reports** — Movement, valuation (on-hand by lot), landed-cost vs invoice-cost, COGS by lot / batch-group views. No dedicated reports feature yet.
- [ ] **Reconcile / WAC UI** — `runFullInventoryReconciliation` has no UI caller; clarify vs lot `effectiveCost` so `purchasePrice` cache does not go stale unnoticed.
- [ ] **Opening stock on create** — `createProductWithOpeningStock` exists; add-product currently starts at qty 0 (opening only via later manual lot). Optional opening qty on create.
- [ ] **Cost-split lineage UI** — `sourceLotUuid` is written; show “Split from …” on new manual lot + optional jump to parent.
- [ ] **Lot hold / exclude from FEFO** — Flag so a lot is not consumed while cost/QC is pending.
- [ ] **SKU scan in stock flows** — `scan_sku_screen` exists; ensure receive / sale / stock-check entry points use it where useful.
- [ ] **Consumed / sales-out history on product** — Per lot or product: which sale/return lines consumed qty; deep link to order.

### Low / later

- [ ] Multi-warehouse / inter-location stock transfer (not money `account_transfers`).
- [ ] Serial / IMEI tracking.
- [ ] Multi-unit conversion (box ↔ piece, etc.).
- [ ] FIFO / MANUAL batch strategies from catalog items (consume path is FEFO-only today).
- [ ] Purchase-lot cost correction via reverse-receive / credit note (do not edit frozen purchase `effectiveCost`).
- [ ] Recoverable tax (VAT/GST) separate from landed `effectiveCost`.
- [ ] Outbound freight as expense/customer charge (never lot cost).
- [ ] Discount vouchers as first-class entities.
- [ ] Strict unique index on `product_batches.shipment_line_uuid` where not null.
- [ ] RBAC / inventory audit log beyond production consumptions + soft-delete.

---

## Already strong (current stage)

- **1 lot ↔ 1 goods-receipt line** for purchase stock; batch # / mfg / expiry / description on lots.
- Line planned unit cost + inbound freight/duty into lot `effectiveCost` (frozen on purchase lots).
- Manual lots (`OPENING` / `PRODUCTION` / `ADJUSTMENT`); cost-split when changing cost with `consumed > 0` (`sourceLotUuid`).
- Product details: hero, on-hand / avg cost / consumed / open lots, lot filters, batch grouping, deep link to PO.
- FEFO consume/peek; sales deliver consumes lots + COGS snapshot; services skip stock.
- Production: recipes, scale, draft/complete/cancel, AUTO/BATCH consume, charges, co-product weights, consumptions audit.
- Low-stock alerts (list + dashboard); sync registration for products, batches, receipts, orders, returns, catalogs, production in `SyncTables`.
- Pending-sync badges on lists/details; dashboard grouped “changes to push” with drill-down.

---

## Design notes (still valid)

### Product master vs catalogs vs lots

- **Add/Edit Product** stays identity-oriented (name, SKU, unit, category, service, min-stock).
- **Sell prices** intended on **catalogs** (virtual pools): selected lots (or product+strategy), own prices and consume policy.
- Same physical product can appear in multiple catalogs at different prices; sale consumption uses that catalog’s subset + strategy.

### Product details — polish

- Expiry-soon filter; cost-split lineage; optional collapsible fully-consumed block; batch-group summary (Σ remaining + value) — see Medium TODOs above.
- Catalog memberships + sales-out history once catalogs / multi-lot lineage exist — see Phase D items in High/Medium lists.

### Tax / freight / vouchers

- Do **not** land recoverable tax into `effectiveCost`.
- Customer delivery (outbound freight) → expense or customer charge, never lot cost.
- Until voucher entities exist, vouchers roll into `orders.discountAmount`.

### Sync

- Goods receipts / lines **are** registered in `SyncTables` (older note below was outdated).
- When adding new stock entities: follow `.cursor/rules/sync-features.mdc`.
