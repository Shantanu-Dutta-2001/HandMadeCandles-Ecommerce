# HandMadeCandles-Ecommerce
Candle API is a high-performance RESTful backend powered by ASP.NET Core 8.0 and Dapper. It provides secure JWT-based authentication, robust SQL Server data management, and automated database initialization scripts. Designed for scalability and speed, it features full OpenAPI documentation (Swagger) and professional-grade security for e-commerce.
# ⚙️ Backend

A robust and secure RESTful API built with ASP.NET Core 8.0 to power the Candle Web e-commerce platform.

## 🛠️ Made With

- **ASP.NET Core 8.0**: High-performance web framework for modern cloud-based apps.
- **Dapper**: Lightweight and fast ORM for seamless database operations.
- **MS SQL Server**: Enterprise-grade relational database management.
- **JWT Authentication**: Secure, stateless user authorization.
- **BCrypt.Net**: Industry-standard password hashing for maximum security.
- **Swagger/OpenAPI**: Interactive API documentation for easy testing.
- **SQL Scripts**: Comprehensive scripts for schema management and seed data.

## ✨ Key Features

- **Secure Auth**: JWT-based authentication and authorization flow.
- **Optimized Data Access**: Blazing-fast queries using Dapper.
- **Automated Database Setup**: SQL scripts for quick database initialization.
- **Scalable Architecture**: Controller-Service pattern for maintainability.
- **Error Handling**: Graceful error management and logging.
- **CORS Configured**: Ready for seamless integration with the frontend.

## 🚀 Getting Started

### Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) (Express or Developer edition)
- [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

### Installation & Setup

1. **Clone the repository**:
  
2. **Database Setup**:
   - Open SSMS and connect to your SQL Server instance.
   - Run the scripts located in the `Scripts` folder in the following order:
     - `01_CreateDatabase.sql`
     - `02_CreateTables.sql`
     - `03_SeedData.sql`
     - `04_StoredProcedures.sql`
   - Alternatively, use the provided `SetupDatabase.bat` if configured.

3. **Configure Connection String**:
   Update `appsettings.json` with your database connection details:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=YOUR_SERVER;Database=CandleDb;User Id=YOUR_USER;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
   }
   ```

4. **Restore & Run**:
   ```bash
   dotnet restore
   dotnet run
   ```

5. **Access Swagger UI**:
   Once the application is running, navigate to:
   `http://localhost:5000/index.html` (or your configured port) to explore the API.

## 📬 Contact & Support

For more projects or collaboration inquiries, feel free to reach out:

- **Portfolio**: [My-Portfolio](https://dev-shantanudutta.github.io)
- **Email**: [Mail-Me-On](mailto:shantanudutta07@gmail.com)

---
*Built with precision for the premium candle experience.*
