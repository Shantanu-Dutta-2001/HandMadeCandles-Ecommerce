using CandleApi.Models;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CandleApi.Controllers.Admin
{
    [Route("api/admin/orders")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminOrdersController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<AdminOrdersController> _logger;

        public AdminOrdersController(IConfiguration configuration, ILogger<AdminOrdersController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        [HttpGet]
        public async Task<IActionResult> GetAllOrders()
        {
            using var connection = CreateConnection();
            var orders = await connection.QueryAsync<Order>("SELECT * FROM Orders ORDER BY Date DESC");
            return Ok(orders);
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] string status)
        {
            using var connection = CreateConnection();
            // Validate status if needed, or trust admin
            var sql = "UPDATE Orders SET Status = @Status WHERE Id = @Id";
            var affected = await connection.ExecuteAsync(sql, new { Status = status, Id = id });
            
            if (affected == 0) return NotFound();
            return Ok();
        }

        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            using var connection = CreateConnection();
            
            var totalRevenue = await connection.ExecuteScalarAsync<decimal>("SELECT ISNULL(SUM(Total), 0) FROM Orders");
            var totalOrders = await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM Orders");
            
            // Group by status
            var statusCounts = await connection.QueryAsync<dynamic>(
                "SELECT Status, COUNT(*) as Count FROM Orders GROUP BY Status");

            return Ok(new 
            { 
                TotalRevenue = totalRevenue, 
                TotalOrders = totalOrders, 
                StatusBreakdown = statusCounts 
            });
        }
    }
}
