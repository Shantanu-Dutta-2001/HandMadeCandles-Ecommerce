# Database Scripts for CandleFantasyDb

This folder contains all SQL scripts for the Candle Fantasy application database, including table schemas, seed data, stored procedures, and utility scripts.

## 🚀 Quick Start

### Option 1: Using Batch File (Easiest)
```bash
# Double-click or run from command prompt
SetupDatabase.bat
```

### Option 2: Using PowerShell
```powershell
# Run the master setup script
.\RunSqlScripts.ps1 -ScriptName "00_MasterSetup.sql"

# Or run individual scripts
.\RunSqlScripts.ps1 -ScriptName "02_CreateTables.sql"
```

### Option 3: Using SQL Server Management Studio (SSMS)
1. Open SSMS and connect to your SQL Server instance
2. Open `00_MasterSetup.sql`
3. Click Execute (F5)

### Option 4: Using sqlcmd
```bash
sqlcmd -S localhost -E -i "00_MasterSetup.sql"
```

## 📁 Script Files

### Setup Scripts (Run in Order)
| Script | Description | Purpose |
|--------|-------------|---------|
| `00_MasterSetup.sql` | **Master Setup Script** | Executes all setup scripts in correct order |
| `01_CreateDatabase.sql` | **Database Creation** | Creates CandleFantasyDb database |
| `02_CreateTables.sql` | **Table Schemas** | Creates all tables with constraints and indexes |
| `03_SeedData.sql` | **Sample Data** | Inserts mock products, users, orders, and reviews |
| `04_StoredProcedures.sql` | **Stored Procedures** | Creates 20+ stored procedures for API operations |

### Utility Scripts
| Script | Description | Purpose |
|--------|-------------|---------|
| `05_UtilityQueries.sql` | **Utility Queries** | Helpful queries for testing, statistics, and validation |
| `06_TestStoredProcedures.sql` | **Procedure Tests** | Test scripts for all stored procedures |
| `99_CleanupDatabase.sql` | **Cleanup Script** | ⚠️ Drops all tables and procedures (USE WITH CAUTION) |

### Helper Scripts
| Script | Description |
|--------|-------------|
| `RunSqlScripts.ps1` | PowerShell script to execute SQL files |
| `SetupDatabase.bat` | Batch file for easy Windows setup |
| `README.md` | This documentation file |

## 🗄️ Database Schema

### Tables Overview
```
Users (Customer Accounts)
├── Id (PK)
├── Name
├── Email (Unique)
├── PasswordHash
├── Role (User/Admin)
└── CreatedAt

Products (Candle Catalog)
├── Id (PK)
├── Name
├── Description
├── Price
├── Image
├── Category
├── Rating
└── CreatedAt

Orders (Customer Orders)
├── Id (PK)
├── UserId (FK → Users)
├── Total
├── Status
├── Date
├── PaymentMethod
└── ShippingAddress

OrderItems (Order Line Items)
├── Id (PK)
├── OrderId (FK → Orders)
├── ProductId (FK → Products)
├── Quantity
└── Price

Reviews (Customer Testimonials)
├── Id (PK)
├── UserName
├── Content
├── Rating
├── Date
└── ProductId (FK → Products)

Messages (Contact Form)
├── Id (PK)
├── Name
├── Email
├── Subject
├── Body
├── CreatedAt
└── IsRead
```

## 📦 Stored Procedures

### Authentication (3 procedures)
- `sp_RegisterUser` - Register new user account
- `sp_GetUserByEmail` - Retrieve user for login
- `sp_GetUserById` - Get user details by ID

### Products (3 procedures)
- `sp_GetAllProducts` - Get all products
- `sp_GetProductById` - Get single product details
- `sp_GetProductsByCategory` - Filter products by category

### Orders (5 procedures)
- `sp_CreateOrder` - Create new order with items (supports JSON)
- `sp_GetUserOrders` - Get all orders for a user
- `sp_GetOrderById` - Get order details with items
- `sp_UpdateOrderStatus` - Update order status
- `sp_GetOrderItemsByOrderId` - Get items for an order

### Reviews (3 procedures)
- `sp_GetLatestReviews` - Get recent reviews
- `sp_GetReviewsByProduct` - Get reviews for specific product
- `sp_CreateReview` - Create new review (auto-updates product rating)

### Messages (3 procedures)
- `sp_CreateMessage` - Create contact message
- `sp_GetAllMessages` - Get all messages (admin)
- `sp_MarkMessageAsRead` - Mark message as read

### Analytics (2 procedures)
- `sp_GetOrderStatistics` - Get order statistics and revenue
- `sp_GetTopSellingProducts` - Get best-selling products

## 🎯 Sample Data Included

### Products (12 Fantasy-Themed Candles)
- Eternal Flame, Midnight Whisper, Forest Spirit
- Dragon's Breath, Wizard's Study, Siren's Call
- Dwarven Hearth, Fae Trickery, Moonlight Serenade
- Alchemist's Gold, Shadow Veil, Crystal Cascade

### Test Users (4 Accounts)
- test@example.com (User)
- admin@candlefantasy.com (Admin)
- john@example.com (User)
- jane@example.com (User)

**Note:** Test password for all users is `Test123!` (hash included in script)

### Sample Orders (3 Orders)
- 1 Delivered order (15 days ago)
- 1 Shipped order (5 days ago)
- 1 Pending order (1 day ago)

### Reviews (6 Customer Reviews)
Fantasy-themed testimonials for various products

### Messages (3 Contact Messages)
Sample contact form submissions

## 🔧 Maintenance

### To Reset Database
```bash
# Run cleanup script (WARNING: Deletes all data!)
sqlcmd -S localhost -E -i "99_CleanupDatabase.sql"

# Then run setup again
sqlcmd -S localhost -E -i "00_MasterSetup.sql"
```

### To Test Stored Procedures
```bash
sqlcmd -S localhost -E -i "06_TestStoredProcedures.sql"
```

### To Run Utility Queries
```bash
sqlcmd -S localhost -E -i "05_UtilityQueries.sql"
```

## ✅ Features

- **Idempotent Scripts** - All scripts use `IF EXISTS` checks
- **Foreign Key Constraints** - Ensures data integrity
- **Indexes** - Optimized for common queries
- **Check Constraints** - Validates data (prices, ratings, status)
- **Default Values** - Sensible defaults for common fields
- **Cascading Deletes** - OrderItems cascade when Order is deleted
- **Transaction Support** - Order creation uses transactions
- **JSON Support** - sp_CreateOrder accepts JSON array of items

## 🔗 Connection String

Update your `appsettings.json` in the CandleApi project:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=CandleFantasyDb;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

## 📝 Notes

- All scripts are designed for **SQL Server 2016+**
- Scripts use **Windows Authentication** by default
- For SQL Server Authentication, modify connection parameters
- All timestamps use `GETDATE()` for server time
- Password hashes in seed data are BCrypt format
- Product images use Unsplash URLs (placeholder images)

## 🆘 Troubleshooting

### sqlcmd not found
Install SQL Server Command Line Utilities:
https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility

### Permission denied
Run scripts as administrator or ensure your SQL Server user has appropriate permissions.

### Database already exists
Either:
1. Run `99_CleanupDatabase.sql` to clean up
2. Manually drop the database in SSMS
3. Scripts will skip existing objects (idempotent)

## 📚 Additional Resources

- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
- [Dapper ORM](https://github.com/DapperLib/Dapper)
- [ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/)
