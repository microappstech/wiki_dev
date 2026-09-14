# Azure DevOps – Restrict Work Items Access

## 1. Create Security Group

**Project → Project settings → Permissions**

* Create group: `Security Review`
* Add authorized users.

## 2. Create Area Path

**Project settings → Project configuration → Areas**

Create:

```text
CVTheque
└── Security
```

## 3. Configure Area Security

**Areas → Security → ... → Security**

### Security Review

* **View work items in this node** → Allow
* **Edit work items in this node** → Allow

### Other groups

For users who must not access the Work Items:

* **View work items in this node** → Deny

## 4. Assign Work Item

When creating/editing the Work Item:

```text
Area Path → CVTheque\Security
```

## 5. Test

* Member of `Security Review` → ✅ Access
* Other users → ❌ No access

> **Important:** Area Path security applies to all Work Items under that Area.
