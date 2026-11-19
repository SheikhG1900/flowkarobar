# Catalogs & selling products — implementation design

Living design doc for sell-side catalogs, virtual selling products (optional bundles), and cost-based price calculation.  
Implement against this doc; update it when decisions change or slices ship.

**Related:** `docs/inventory-lot-costing-future.md` (stock/lots backlog).  
**Not in scope here:** production recipes (recipes are for making stock; selling products are virtual sell offers only).

---

## Goals

1. Sell through **catalogs** (price lists), not by relying on `product.retailPrice` long-term.
2. Support **simple** sells (product or service) and **optional bundles** without inventing physical “kit” stock.
3. Derive catalog **sell prices** from **unit cost** using % + fixed amount; store the **final price** for orders.
4. Keep **catalogs simple** — no batch/consume strategy on catalog lines.
5. Keep **batch** as an organizational label on lots (already editable / movable).

---

## Concept map

| Concept | What it is | Stock? |
|---------|------------|--------|
| **Stock product** | `Products` with `isService = false` | Yes — lots, FEFO, avg cost |
| **Service product** | `Products` with `isService = true` | No — no lots |
| **Selling product** | Virtual sell offer (name + optional component BOM) | No — never its own lots |
| **Catalog** | Named price list; assigned to contacts | N/A |
| **Catalog item** | One sellable line in a catalog + pricing fields | N/A |
| **Lot batch** | Organizational label on a lot (`batchNumber`) | Label only; one batch per lot |

**Recipes / production** are unrelated to selling products. Recipe inputs were only an analogy for “list of products × qty.”

```
Contact ──< CatalogAssignment >── Catalog
                                    │
                                    └──< CatalogItem
                                           ├── productUuid          XOR
                                           └── sellingProductUuid
                                                 └──< SellingProductComponent >── Product
                                                       (qty, consumeMode, batchNumber?)
```

---

## Selling products

### Rules

- Virtual only — **no** stock row, **no** production link.
- **Not mandatory** for every sale: catalog may link **directly** to a product (stock or service).
- Use a selling product when you need:
  - a **bundle** (multiple products × qty), and/or
  - **batch-scoped** consume on one or more components (AUTO vs BATCH, same idea as recipe inputs).

### Suggested tables

#### `selling_products`

| Column | Type | Notes |
|--------|------|--------|
| `uuid` | PK | |
| `name` | text | Display name of the offer |
| `sku` | text? | Optional code |
| `description` | text? | |
| `categoryUuid` | FK? → product_categories | Optional; if unset at save, defaults from first component product’s category |
| `unit` | text? | Optional sell unit; if unset at save, defaults from first component product’s unit |
| `createdAt` / `updatedAt` | | |
| `isDeleted` / `isNotSynced` | | Soft-delete + sync (follow `sync-features.mdc`) |

No sell price on this table.

#### `selling_product_components`

| Column | Type | Notes |
|--------|------|--------|
| `uuid` | PK | |
| `sellingProductUuid` | FK → selling_products | |
| `productUuid` | FK → products | Component (prefer stock products; services allowed if needed) |
| `quantity` | real | Qty consumed per **1** selling unit |
| `consumeMode` | text | `AUTO` \| `BATCH` (align with production consume modes) |
| `batchNumber` | text? | Required when `consumeMode = BATCH`; virtual batch label |
| `createdAt` / `updatedAt` | | |
| `isDeleted` / `isNotSynced` | | |

**v1 constraints**

- No nested selling products (component must be a `Products` row).
- Empty component list is invalid if the row is used as a selling product — prefer direct product link on catalog instead of a zero-BOM selling product.
- Single-component selling product is allowed (e.g. only to pin BATCH consume).

### Deliver / consume (when sales use catalogs)

- Catalog item → **product**: if service, no stock move; if stock, FEFO **AUTO** across open lots.
- Catalog item → **selling product**: for each component, consume `qty × orderLineQty` with that component’s `AUTO` / `BATCH` rules.

Availability for a selling product (sellable qty):

```text
min over components of floor(available(component) / qtyPerUnit)
```

(Batch-scoped availability when mode is BATCH.)

---

## Catalogs

### Keep catalogs simple

Catalog items do **not** store:

- batch selection strategy  
- batch uuid / batch number  
- consume mode  

Those live on **selling product components** (or default AUTO for direct product links).

### Link: two nullable FKs (XOR)

On each catalog item, **exactly one** of:

- `productUuid` — direct stock or service product  
- `sellingProductUuid` — virtual offer / bundle  

Enforce in app (and ideally DB check / validation).

### Existing schema to evolve

Today (`CatalogItems`): `productUuid` (required), `customPrice`, `batchUuid`, `batchSelectionStrategy`, `validUntil`, plus `CatalogTieredDiscounts`.

**Target direction**

- Make `productUuid` nullable; add `sellingProductUuid` nullable; XOR.
- Replace “price only as customPrice” with explicit pricing fields (below).
- **Stop using** `batchUuid` / `batchSelectionStrategy` on catalog items for new work (deprecate / ignore / migrate away).
- `CatalogAssignments` (catalog ↔ contact) — keep.
- `CatalogTieredDiscounts` — **later** (apply on top of stored sell price); not required for v1.

### Catalog header

Keep / use: `name`, `description`, `validUntil`, `isDefault`, soft-delete, sync.

Optional later: catalog-level **defaults** for approach / % / fixed (convenience only; not a live shared rule).

---

## Pricing model

### Important: not calculated at order time

1. When adding/updating catalog lines, compute **final sell price** from unit cost + formula inputs.
2. **Persist** final price **and** the formula inputs on the catalog item.
3. **Orders** use the stored sell price (and should **snapshot** it on the order line).  
   Do **not** re-run % / fixed at deliver/sale time.

Formula fields exist so the user can **refresh / recalculate an item’s price individually** (or in bulk) when costs change.

### Unit cost base

| Target | Unit cost |
|--------|-----------|
| **Service product** | Product-level cost (use `purchasePrice` as cost, or 0) |
| **Stock product (overall)** | Weighted avg of **open** lots: `Σ(remaining × effectiveCost) / Σ(remaining)`. If no open stock → fall back to `purchasePrice` (or 0). |
| **Stock product (batch scope)** | Same average, limited to lots with that `batchNumber` (when selling-product component uses `BATCH`). |
| **Selling product** | `Σ (componentUnitCost × componentQty)` using the rules above per component |

### Formula approaches (4 options; store on each catalog item)

UI shows a **scenario hint** for each option so users pick the business meaning, not only the algebra.

| Code | Scenario | Formula |
|------|----------|---------|
| `MARKUP` | Mark up cost, then add packing/delivery | `sell = cost × (1 + %/100) + fixed` |
| `MARKUP_ON_BASE` | Fold extras into cost, then mark up everything | `sell = (cost + fixed) × (1 + %/100)` |
| `MARGIN` | Cover a flat fee and hit margin on sell | `sell = (cost + fixed) / (1 − %/100)` |
| `MARGIN_THEN_FIXED` | Hit margin on cost, then add flat extra profit | `sell = cost / (1 − %/100) + fixed` |

Require `percent < 100` for both margin options. Existing rows with `MARKUP` / `MARGIN` keep the same meaning.

### Fields on each catalog item (pricing)

| Field | Notes |
|-------|--------|
| `pricingApproach` | `MARKUP` \| `MARKUP_ON_BASE` \| `MARGIN` \| `MARGIN_THEN_FIXED` |
| `markupOrMarginPercent` | real, default 0 |
| `fixedAmount` | real, default 0 |
| `sellPrice` | final computed (or manually overridden) price |
| `unitCostSnapshot` | optional but useful — cost used when price was last computed |
| `priceComputedAt` | optional — when last refreshed |
| `priceOverride` | bool — true when sell price was set manually; skipped by catalog recalculate; UI shows `*` |
| `defaultDiscountType` | `PERCENT` \| `FIXED` \| null — always-on discount when no qty tier matches |
| `defaultDiscountValue` | real — % or fixed amount per unit |

### Qty tiers (`catalog_tiered_discounts`)

| Field | Notes |
|-------|--------|
| `catalogItemUuid` | FK → catalog item |
| `minQuantity` | Apply when order qty ≥ this |
| `discountType` | `PERCENT` \| `FIXED` |
| `discountPercentage` | used when type is PERCENT |
| `discountAmount` | used when type is FIXED (per unit) |

**Apply rule (order/quotation):** start from `sellPrice`; if a tier matches qty, use that tier **instead of** the item default (no stacking). Snapshot the result on the order line.

### Add-to-catalog UX (agreed flow)

1. User selects one or many **products and/or selling products**.
2. User sets a **common** calculation for **this selection only**: approach + % + fixed.
3. App computes each line’s `sellPrice` from that item’s unit cost.
4. Each line is inserted with **its own copy** of approach / % / fixed / sellPrice (and optional cost snapshot).
5. After insert, lines are **independent** — edit or refresh one without affecting others.

The common calculation is **bulk input at add time**, not a permanent catalog-wide live rule.

### Add whole catalog into a catalog

From target catalog **B**, action: **Add from catalog…** → pick source catalog **A**.

- Creates **new catalog item rows** under B. Does **not** share A’s item rows.
- Underlying `productUuid` / `sellingProductUuid` are **referenced** (same masters), not duplicated.
- Contact assignments are **not** copied by this action.
- Soft-deleted items in A are skipped.

**Price mode (user chooses once for the import)**

| Option | Behavior |
|--------|----------|
| **Copy prices** | Copy approach, %, fixed, and `sellPrice` (and optional cost snapshot) from each source item as-is. |
| **Recalculate prices** | Copy approach, %, fixed from each source item; recompute `sellPrice` from **current** unit cost before insert. |

**Duplicate handling**

A duplicate means B already has an active item with the same link target (same `productUuid` **or** same `sellingProductUuid`).

When a conflict is found, prompt per item (with remember-for-rest actions):

| Action | Behavior |
|--------|----------|
| **Skip** | Leave B’s existing item unchanged; do not import this source row. |
| **Replace** | Update B’s existing item from the source row (pricing fields per price mode above; keep B’s item uuid). |
| **Skip all** | Skip this and all further conflicts in this import. |
| **Replace all** | Replace this and all further conflicts in this import. |

Non-conflicting source items are always inserted as new rows.

### Refresh price

- Per item (and optionally multi-select): re-read unit cost → apply stored approach/%/fixed → write new `sellPrice`.
- Does not change historical orders (order lines already snapshotted).

### Recalculate whole catalog (in place)

Users should **not** need to copy a catalog just because costs changed or the list “expired.” They can refresh prices on the **same** catalog.

**Action:** on catalog detail — **Recalculate prices** (whole catalog).

For every active item in that catalog:

1. Resolve **current** unit cost (product / batch scope / selling-product sum).
2. Apply that item’s stored **approach + % + fixed** (unchanged).
3. Write new **`sellPrice`** (and optional `unitCostSnapshot` / `priceComputedAt`).

**Safety:** past orders keep their **order-line price snapshots**. Recalc only updates catalog items; historical sales are unaffected.

**UX**

- Confirm: e.g. “Update sell prices for N items from current costs?”
- After run: short summary (updated / skipped — e.g. invalid margin % ≥ 100).
- Optional: also extend / clear `validUntil` in a separate edit — recalc does not imply changing validity unless the user edits the header.

**When to use what**

| Action | Use when |
|--------|----------|
| **Recalculate catalog** | Same catalog; refresh sell prices from current costs |
| **Add from catalog** | Merge/import another catalog’s items into this one |
| **Duplicate / new catalog** | Need a **second** distinct price list (e.g. wholesale vs retail) |

---

## Lot batch (organizational) — already decided / partially shipped

- Batch = virtual label on the lot; **one batch per lot**.
- User may **move** any lot (purchase or manual) to another batch (e.g. `SHORT-EXPIRY`).
- Implemented: `InventoryRepository.updateLotBatchNumber` + product-details change-batch UI.
- Optional later: immutable `receivedBatchNumber` vs editable operational `batchNumber` for audit.

---

## Sales integration (when wiring orders)

1. Resolve customer → assigned catalog (or default catalog).
2. Picker lists **catalog items** (show name from product or selling product + `sellPrice`).
3. Order line stores: catalog item ref, product and/or selling product ref, **list `unitPrice`**, **`discountedUnitPrice`**, derived line `discountAmount`, qty, **`catalogNameSnapshot`**.
4. New Sale UI: qty editable by default; catalog chip per line; read-only unit / discounted / unit-discount / line-discount / line-total. Optional unlock to edit discounted unit price (then qty keeps that price until refresh). Refresh re-fetches catalog item tiers + sell price.
5. On deliver: consume per rules above; COGS from consumed lots (bundle = sum of component consumptions).
6. Returns: restock components / product per lineage (depends on sale multi-lot lineage backlog).

---

## Sync & app conventions

- Register new tables in `SyncTables`; soft-delete only; `isNotSynced` on write.
- Follow `.cursor/rules/sync-features.mdc` and `.cursor/rules/feature-consistency.mdc`.
- Amounts: `AmountFormatter`; dates: `AppDateFormatter`; toasts: `ToastUtils`.
- l10n: EN + HI + UR for all user-facing strings.
- Prefer theme / `AppColors` over one-off colors.

---

## Implementation checklist

Follow **in order**. Mark each step `[x]` when done. Do not start a later phase until the previous phase’s required steps are complete (Phase 5 is optional / later).

**Progress:** Phase 1 ☑ · Phase 2 ☑ · Phase 3 ☑ · Phase 4 ☑ · Phase 5 (partial: 5.1/5.2/5.3 ☑)

---

### Phase 1 — Data model & domain helpers

**Goal:** Schema + sync + pure pricing/cost helpers. No feature UI yet (except what you need to smoke-test).

- [x] **1.1** Add Drift tables `selling_products` and `selling_product_components` (columns per this doc); regenerate Drift code.
- [x] **1.2** Evolve `catalog_items`:
  - [x] Make `productUuid` nullable.
  - [x] Add nullable `sellingProductUuid` (XOR with `productUuid`).
  - [x] Add `pricingApproach`, `markupOrMarginPercent`, `fixedAmount`, `sellPrice` (and optional `unitCostSnapshot` / `priceComputedAt`).
  - [x] Stop using `batchUuid` / `batchSelectionStrategy` for new logic (leave columns deprecated or migrate away).
- [x] **1.3** Schema migration for existing DBs; safe defaults for any pre-existing catalog rows.
- [x] **1.4** Register new/changed tables in `SyncTables`; soft-delete + `isNotSynced` on writes.
- [x] **1.5** Domain helpers (unit-testable):
  - [x] Unit cost: service / stock overall / stock by batch / selling-product sum.
  - [x] Sell price: `MARKUP` and `MARGIN` formulas (locked order of % + fixed).
- [x] **1.6** Repository stubs: CRUD selling products + components; catalog item insert/update with XOR validation.
- [x] **1.7** Mark Phase 1 progress ☐ → ☑ above when 1.1–1.6 done.

---

### Phase 2 — Selling products UI

**Goal:** Users can define virtual offers / bundles (no catalog pricing yet).

- [x] **2.1** Navigation entry + list screen (search, soft-deleted hidden, pending-sync badge).
- [x] **2.2** Create / edit selling product (name, sku, description, category, unit; default category/unit from first component if unset).
- [x] **2.3** Component editor: product picker, qty, `AUTO` | `BATCH`, batch picker when BATCH.
- [x] **2.4** Validation: at least one component; BATCH requires batch label; no nested selling products.
- [x] **2.5** Soft-delete selling product (+ components policy); detail screen with pending-sync.
- [x] **2.6** l10n EN / HI / UR for all new strings.
- [x] **2.7** Mark Phase 2 progress ☐ → ☑ when 2.1–2.6 done.

---

### Phase 3 — Catalogs UI

**Goal:** Full price-list management; sales still may use `retailPrice` until Phase 4.

- [x] **3.1** Catalog list / create / edit header (`name`, `description`, `validUntil`, `isDefault`).
- [x] **3.2** Catalog detail: list items with sell price + link target name; pending-sync.
- [x] **3.3** Add items from products + selling products:
  - [x] Multi-select.
  - [x] Common calculation sheet (approach + % + fixed) for this selection only.
  - [x] Insert lines with **individual** copied pricing fields + computed `sellPrice`.
- [x] **3.4** Edit single catalog item pricing; optional per-item refresh price.
- [x] **3.5** **Add from catalog:** pick source catalog; price mode Copy vs Recalculate; conflicts Skip all / Replace all.
- [x] **3.6** **Recalculate whole catalog** in place (confirm + summary); orders unaffected.
- [x] **3.7** Contact ↔ catalog assignment UI.
- [x] **3.8** l10n EN / HI / UR.
- [x] **3.9** Mark Phase 3 progress ☐ → ☑ when 3.1–3.8 done.

---

### Phase 4 — Sales integration

**Goal:** Orders sell from catalogs; consume stock for products and selling-product bundles.

- [x] **4.1** Resolve customer → assigned **active** catalog (or active default); if none → **block** adding sale items.
- [x] **4.2** Sale line picker from catalog items (show name + stored sell price).
- [x] **4.3** Persist on order line: `catalogItemUuid`, nullable `productUuid` / `sellingProductUuid`, **list `unitPrice` + `discountedUnitPrice`**, qty, line `discountAmount`, `catalogNameSnapshot`.
- [x] **4.4** Deliver: direct product consume (AUTO FEFO) or selling-product component explosion (AUTO/BATCH).
- [x] **4.5** COGS from consumed lots (bundle = sum of component allocations / qty).
- [ ] **4.6** Align with sale multi-lot lineage backlog where needed (returns accuracy) — bundles leave `batchUuid` null for now.
- [x] **4.7** Policy: sale items **catalog-only** from active catalog; no retail product picker on sale.
- [x] **4.8** Mark Phase 4 progress ☐ → ☑ when 4.1–4.7 done.
- [x] **4.9** Historical sale detail: highlight lines whose catalog item/catalog is deleted or catalog expired; warn before deliver.

---

### Phase 5 — Later (optional)

- [x] **5.1** Default + tiered discounts on catalog items (`PERCENT` / `FIXED`; copy on bulk add; edit on item; apply at order later).
- [x] **5.2** Catalog-level default approach / % / fixed for new lines (edit catalog; prefill Add items).
- [x] **5.3** Manual sell-price override flag (skip on catalog recalculate; confirm on single refresh; `*` marker).
- [ ] **5.4** Reports: margin vs cost at catalog / sale.
- [ ] **5.5** **Product images (next iteration):** store gallery on **products** (master identity); optional cover/gallery on **selling products** only when the offer needs its own pack shot. Catalog list/detail/sale pickers resolve image via linked `productUuid` / `sellingProductUuid` — **do not** put images on `catalog_items` for v1. Optional later: rare catalog-only image override on an item.
- [ ] **5.6** **Hierarchical catalog browse (next iteration):** for large catalogs, add a drill-down structure (e.g. departments → groups → items, or nested categories) so users can browse/pick by hierarchy instead of one flat list. Prefer reusing/extending **product categories** where possible; if catalog-specific grouping is needed, keep structure separate from price rows (don’t flatten hierarchy into `catalog_items`). Sale picker and catalog detail should support the same drill-down.
- [ ] **5.7** Mark Phase 5 progress when adopted items are done.

---

## Decision log (locked for v1)

| Topic | Decision |
|-------|----------|
| Selling product vs recipe | Unrelated; selling product is virtual sell offer only |
| Bundle stock | Virtual kit — consume components on deliver; no kit lot |
| Catalog batch strategy | Not on catalog item |
| Catalog link | `productUuid` XOR `sellingProductUuid` |
| Services | Direct product link; cost from product field |
| Stock unit cost | Open-lot weighted average (batch-scoped when component says BATCH) |
| Price at order | Snapshot list `unitPrice` + `discountedUnitPrice` (discount from their difference); optional refresh from catalog |
| % + fixed meaning | Stored per catalog item for individual/bulk refresh |
| Bulk add | Common formula for selection → copied onto each new line |
| Import catalog → catalog | New item rows; Copy prices or Recalculate; conflicts: Skip / Replace / Skip all / Replace all |
| Recalculate whole catalog | In-place refresh of formula items from current cost; skip `priceOverride`; orders unaffected |
| Markup vs margin | Four approaches (markup/margin × fixed before/after) via `pricingApproach` |
| Fixed vs % order | Chosen per item via the four scenario options |
| Lot multi-batch | No — one operational batch per lot; move to reclassify |
| Product images | On **product** (and optional selling-product pack shot); not on catalog items for v1; catalog/sale UI inherits via link |
| Large-catalog grouping | Hierarchical drill-down (next iteration); prefer product categories; keep hierarchy off price rows |
| Sale catalog visibility | Catalog with **no** contact assignments → all customers + walk-in; with assignments → those contacts only |
| Sale catalog order | Always **default first**, then **name A–Z** (same in list + drawer) |
| Sale catalog resolve | Among eligible: assigned (same order) else first eligible; bottom drawer picker; **block add** when none |
| Active catalog | Not deleted; `validUntil` null or today-or-later |
| Assigned/default catalog pricing | Use catalog `sellPrice` (+ default/tier discounts at order); not `product.retailPrice` |
| Historical sale lines | Keep price snapshot; highlight if catalog item/catalog deleted or catalog expired; warn on deliver |

---

## Open points (resolve during implementation if needed)

1. ~~Sale picker when contact has **no** catalog~~ → **Locked:** assignment → default (**active only**); if none → **block** adding sale items (no retail fallback).
2. Can selling-product components include **services** (e.g. product + installation)? (Deliver stamps service component cost from `purchasePrice`; no stock consume.)
3. Display name on catalog line when linking a product: always product name, or allow catalog-only alias?
4. Exact fallback when open stock is 0 but `purchasePrice` is also 0 (allow sellPrice = fixed only — recommended yes).
