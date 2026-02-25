# NGO Assistance Management System — Role-Based Access Control (RBAC)

## Overview

The system implements **4 user roles** across the NGO workflow. Each role has specific permissions, screens, and capabilities mapped to the business process flow.

---

## User Roles & Permissions Matrix

| Feature / Screen               | NGO Admin (User B) | NGO Staff (User A) | Vendor        | Field Verifier |
|--------------------------------|:-------------------:|:-------------------:|:-------------:|:--------------:|
| **Dashboard**                  | ✅ Full Analytics   | ✅ Staff View       | ✅ Store View  | ✅ Basic        |
| **Register Beneficiary**       | ✅                  | ✅ (Primary)        | ❌             | ❌              |
| **Upload Documents**           | ✅                  | ✅ (Primary)        | ❌             | ❌              |
| **Search Beneficiary (CNIC)**  | ✅                  | ✅                  | ✅ (Assigned)  | ✅              |
| **View Beneficiary List**      | ✅ All              | ✅ All              | ✅ Assigned    | ✅ Assigned     |
| **Approve / Reject Beneficiary** | ✅ (Primary)      | ❌ View Only        | ❌             | ❌              |
| **Define Assistance Cases**    | ✅ (Primary)        | ❌                  | ❌             | ❌              |
| **Manage Assistance Cases**    | ✅                  | ✅ View + Monitor   | ❌             | ❌              |
| **Assign Vendors/Stores**      | ✅                  | ✅                  | ❌             | ❌              |
| **View Entitlements**          | ✅ All              | ✅ All              | ✅ Own Store   | ❌              |
| **Monitor Monthly Cycles**     | ✅                  | ✅                  | ✅ Own Store   | ❌              |
| **Mark Assistance Delivered**  | ❌                  | ❌                  | ✅ (Primary)   | ❌              |
| **Verify Beneficiary Identity**| ❌                  | ❌                  | ✅ At Store    | ✅ (Primary)    |
| **Upload Verification Notes**  | ❌                  | ❌                  | ❌             | ✅ (Primary)    |
| **Manage Users / Personnel**   | ✅ (Primary)        | ❌                  | ❌             | ❌              |
| **Onboard Vendors**           | ✅ (Primary)        | ❌                  | ❌             | ❌              |
| **View Analytics / Reports**   | ✅ All Reports      | ✅ Limited          | ✅ Own Store   | ❌              |
| **Download Reports (PDF/Excel)** | ✅ All            | ✅ Assigned         | ✅ Own Store   | ❌              |
| **View Audit Logs**            | ✅ (Primary)        | ❌                  | ❌             | ❌              |

---

## Role Details

### 1. NGO Admin / Supervisor (User B)
**Database Role:** `NGO_ADMIN` or `SUPER_ADMIN`

**Purpose:** Oversees the entire assistance program. Approves beneficiaries, defines assistance rules, manages users, and monitors all operations.

**Sidebar Navigation (All Items):**
| # | Icon | Label | Screen |
|---|------|-------|--------|
| 0 | 🏠 | DASHBOARD | Admin Dashboard (full analytics) |
| 1 | 👥 | BENEFICIARIES | Beneficiary List (all statuses) |
| 2 | 🤝 | ASSISTANCE | Assistance Cases (create, pause, close) |
| 3 | 🏪 | PARTNERS | Vendor Management (onboard, edit) |
| 4 | 💰 | ENTITLEMENTS | Monthly Entitlements (all) |
| 5 | ✅ | APPROVALS | Approve/Reject pending beneficiaries |
| 6 | 👤 | PERSONNEL | User Management (create staff, assign roles) |
| 7 | 📊 | ANALYTICS | Reports Dashboard (all reports) |
| 8 | 📜 | AUDIT LOGS | Full audit trail |

**Key Workflow:**
```
Pending Beneficiary → Admin Reviews → APPROVE or REJECT
                                        ↓ (if approved)
                                  Define Assistance Case:
                                    • Assistance Type (Ration/Rent/Medical/Marriage/Emergency)
                                    • Monthly Amount
                                    • Assign Vendor/Store
                                    • Duration
                                    • Approval Notes
                                        ↓
                                  Case set to ACTIVE
                                  Monthly entitlements auto-generated
```

**Available Reports:**
- Monthly Assistance Summary
- Vendor-wise Allocation Report
- Beneficiary Listing
- Verification Pipeline Status
- Exception & Fraud Attempts

---

### 2. NGO Back-Office Staff (User A)
**Database Role:** `NGO_STAFF`

**Purpose:** Handles day-to-day operations — registers beneficiaries, uploads documents, manages verification workflow, assigns vendors, and monitors monthly cycles.

**Sidebar Navigation:**
| # | Icon | Label | Screen |
|---|------|-------|--------|
| 0 | 🏠 | DASHBOARD | Staff Dashboard |
| 1 | 👥 | BENEFICIARIES | Register & manage beneficiaries |
| 2 | 🤝 | ASSISTANCE | View & monitor assistance cases |
| 4 | 💰 | ENTITLEMENTS | Monitor monthly entitlements |
| 7 | 📊 | ANALYTICS | Generate staff-level reports |

**Key Workflow:**
```
Staff Registers Beneficiary:
  • Full Name, Father/Husband Name
  • CNIC (unique), Mobile, City/Area/Address
  • Upload Photo & Documents (CNIC Front, CNIC Back, etc.)
  • Status → PENDING
        ↓
  Sent to Verification Team
        ↓
  Verified → Sent to Approval Queue (Admin)
  Failed → REJECTED with reason
```

**Cannot:**
- Approve/reject beneficiaries (that's Admin only)
- Manage users or roles
- View audit logs
- Onboard vendors

---

### 3. Vendor / Store (Vendor Admin & Vendor User)
**Database Roles:** `VENDOR_ADMIN`, `VENDOR_USER`

**Purpose:** Receives assigned beneficiaries, verifies their identity at the store, and marks assistance as delivered (redeemed).

**Sidebar Navigation:**
| # | Icon | Label | Screen |
|---|------|-------|--------|
| 0 | 🏠 | DASHBOARD | Vendor Dashboard (own store stats) |
| 1 | 👥 | BENEFICIARIES | View assigned beneficiaries only |
| 7 | 📊 | ANALYTICS | Own store reports |

**Key Workflow:**
```
Beneficiary visits assigned store
        ↓
  Vendor verifies identity (biometric/photo)
        ↓
  If verified → Mark Assistance as DELIVERED (REDEEMED)
  If failed → Report fraud incident
```

**Available Reports (Own Store Only):**
- Monthly Assigned Beneficiaries
- Redeemed vs Pending
- Daily Redemption Logs

**Cannot:**
- Register beneficiaries
- Approve/reject applications
- View other stores' data
- Manage users

---

### 4. Field Verification Team
**Database Role:** `FIELD_VERIFIER`

**Purpose:** Performs on-ground manual verification of beneficiaries. Uploads verification notes and evidence.

**Sidebar Navigation:**
| # | Icon | Label | Screen |
|---|------|-------|--------|
| 0 | 🏠 | DASHBOARD | Basic Dashboard |
| 1 | 👥 | BENEFICIARIES | View assigned for verification |

**Key Workflow:**
```
Receives pending verification assignments
        ↓
  Visit beneficiary location
        ↓
  Perform manual verification:
    • Check documents (CNIC, proof)
    • Verify address & living conditions
    • Take evidence photos
        ↓
  Upload verification result:
    • VERIFIED → Moves to Admin approval queue
    • FAILED → REJECTED with reason & evidence
```

**Cannot:**
- Register beneficiaries
- Approve/reject applications
- View reports or analytics
- Manage anything

---

## Database Enum Mapping

### User Roles (Prisma Schema)
```prisma
enum UserRole {
  SUPER_ADMIN      // Full system access (same as NGO_ADMIN + system config)
  NGO_ADMIN        // User B — Approver, manager
  NGO_STAFF        // User A — Registration, operations
  VENDOR_ADMIN     // Store manager
  VENDOR_USER      // Store staff
  FIELD_VERIFIER   // Verification team
}
```

### Beneficiary Status Flow
```
PENDING → VERIFIED → APPROVED → [ACTIVE assistance case]
   ↓         ↓          ↓
REJECTED  REJECTED   SUSPENDED → CLOSED
```

### Assistance Types
```prisma
enum AssistanceType {
  RATION       // Food/grocery assistance via assigned store
  RENT         // Monthly rent support
  MEDICAL      // Healthcare assistance
  MARRIAGE     // Marriage support
  EMERGENCY    // One-time emergency aid
}
```

### Assistance Case Status
```
ACTIVE → PAUSED → CLOSED
   ↓
CLOSED (no future entitlements generated)
```

### Monthly Entitlement Status
```
NOT_REDEEMED → REDEEMED (delivered at store)
      ↓
   EXPIRED (month passed without redemption)
      ↓
   BLOCKED (beneficiary suspended)
```

---

## Flutter Implementation

### Navigation Mapping (`main_shell.dart`)

```dart
switch (role) {
  case UserRole.ngoStaff:
    // Screens: Dashboard, Beneficiaries, Assistance, Entitlements, Analytics
    screenIndices: [0, 1, 2, 4, 7]

  case UserRole.vendorAdmin:
  case UserRole.vendorUser:
    // Screens: Dashboard, Beneficiaries (assigned), Analytics (own store)
    screenIndices: [0, 1, 7]

  case UserRole.fieldVerifier:
    // Screens: Dashboard, Beneficiaries (verification)
    screenIndices: [0, 1]

  default: // NGO_ADMIN, SUPER_ADMIN
    // ALL screens: [0, 1, 2, 3, 4, 5, 6, 7, 8]
}
```

### Screen Index Reference
```
0 = Dashboard
1 = Beneficiary List / Registration
2 = Assistance Cases
3 = Vendor/Partner Management
4 = Entitlements
5 = Approvals (Admin only)
6 = User/Personnel Management (Admin only)
7 = Analytics/Reports
8 = Audit Logs (Admin only)
```

---

## Business Rules (Critical)

| # | Rule | Enforcement |
|---|------|-------------|
| 1 | CNIC must be unique per beneficiary | Database `@unique` constraint on `cnic` field |
| 2 | One entitlement per beneficiary per month per assistance case | Database `@@unique([assistance_case_id, month])` |
| 3 | Beneficiary can redeem only from assigned store | Backend validates `vendor_id` match during redemption |
| 4 | Pending/Suspended/Closed beneficiaries cannot redeem | Backend checks `beneficiary.status` before redemption |
| 5 | Redemption requires biometric and/or photo verification | `redemption` table stores `biometric_ref` and `photo_url` |
| 6 | All actions must be logged (audit trail) | `auditMiddleware` logs all POST/PUT/PATCH/DELETE to `audit_logs` |
| 7 | Store capacity limits (future) | `store_capacity` table exists in schema for future use |

---

## Login Credentials (Seed Data)

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@ngo.org` | `admin123` |
| Staff | `staff1@ngo.org` | `staff123` |
| Staff | `staff2@ngo.org` | `staff123` |
| Vendor (Metro) | `vendor@metrocash&carry.com` | `vendor123` |
| Vendor (Imtiaz) | `vendor@imtiazsupermarket.com` | `vendor123` |
| Vendor (Save Mart) | `vendor@savemart.com` | `vendor123` |

---

## Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    NGO Staff (User A)                        │
│                                                             │
│  Register Beneficiary → Upload Docs → Status: PENDING       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  Field Verification Team                     │
│                                                             │
│  Manual Verification → Upload Notes/Evidence                │
│  Result: VERIFIED ✓ or REJECTED ✗                           │
└──────────────────────────┬──────────────────────────────────┘
                           │ (if VERIFIED)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   NGO Admin (User B)                         │
│                                                             │
│  Review Application → APPROVE or REJECT                     │
│  If Approved:                                               │
│    → Define Assistance Case                                 │
│    → Set Type (Ration/Rent/Medical/Marriage/Emergency)       │
│    → Set Amount, Duration, Assign Vendor                    │
│    → Case Status: ACTIVE                                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              System (Automatic Monthly Job)                  │
│                                                             │
│  Generate Monthly Entitlements for all ACTIVE cases          │
│  Group by assigned vendor                                   │
│  Status: NOT_REDEEMED                                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Vendor / Store                            │
│                                                             │
│  Beneficiary visits store                                   │
│  → Verify identity (biometric/photo)                        │
│  → Mark as DELIVERED (REDEEMED)                             │
│  → Log redemption with evidence                             │
└─────────────────────────────────────────────────────────────┘
```

---

*Document generated: 2026-02-24*
*System: NGO Assistance Management System (Flutter + Node.js + Prisma + PostgreSQL)*
