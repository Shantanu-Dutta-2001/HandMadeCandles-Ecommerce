using CandleApi.Models;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Security.Claims;

namespace CandleApi.Controllers
{
    [Route("api/orders")]
    [ApiController]
    [Authorize]
    public class OrderFeedbackController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<OrderFeedbackController> _logger;

        public OrderFeedbackController(IConfiguration configuration, ILogger<OrderFeedbackController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        [HttpPost("{orderId}/feedback")]
        public async Task<IActionResult> SubmitFeedback(int orderId, OrderFeedback feedback)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            
            using var connection = CreateConnection();

            // validation: check if order belongs to user and is delivered
            var order = await connection.QueryFirstOrDefaultAsync<Order>(
                "SELECT * FROM Orders WHERE Id = @Id AND UserId = @UserId", 
                new { Id = orderId, UserId = userId });

            if (order == null) return NotFound("Order not found or access denied.");
            if (order.Status != "Delivered") return BadRequest("Feedback can only be submitted for delivered orders.");

            // validation: check if feedback already exists
            var existing = await connection.QueryFirstOrDefaultAsync<OrderFeedback>(
                "SELECT * FROM OrderFeedbacks WHERE OrderId = @OrderId", 
                new { OrderId = orderId });

            if (existing != null) return BadRequest("Feedback already submitted for this order.");

            feedback.OrderId = orderId;
            feedback.UserId = userId;
            
            var sql = @"
                INSERT INTO OrderFeedbacks (OrderId, UserId, Rating, Message, Date) 
                VALUES (@OrderId, @UserId, @Rating, @Message, GETDATE());
                SELECT CAST(SCOPE_IDENTITY() as int)";

            var id = await connection.ExecuteScalarAsync<int>(sql, feedback);
            feedback.Id = id;

            return Ok(feedback);
        }

        [HttpGet("{orderId}/feedback")]
        public async Task<IActionResult> GetFeedback(int orderId)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");

            using var connection = CreateConnection();
            
            // Verify access
            var order = await connection.QueryFirstOrDefaultAsync<Order>(
                "SELECT * FROM Orders WHERE Id = @Id AND UserId = @UserId",
                new { Id = orderId, UserId = userId });

            if (order == null) return NotFound("Order not found.");

            var feedback = await connection.QueryFirstOrDefaultAsync<OrderFeedback>(
                "SELECT * FROM OrderFeedbacks WHERE OrderId = @OrderId",
                new { OrderId = orderId });

            return Ok(feedback); // Returns null (200 OK) if no feedback yet
        }
    }
}
