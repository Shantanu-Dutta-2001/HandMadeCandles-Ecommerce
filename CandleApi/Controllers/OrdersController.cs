using System.Security.Claims;
using CandleApi.Models;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CandleApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class OrdersController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<OrdersController> _logger;

        public OrdersController(IConfiguration configuration, ILogger<OrdersController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        [HttpPost]
        public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
        {
            var timestamp = DateTime.UtcNow;
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            
            _logger.LogInformation("[{Timestamp}] Order creation started - UserId: {UserId}, Total: {Total}, Items: {ItemCount}", 
                timestamp, userId, dto.Total, dto.Items.Count);

            using var connection = CreateConnection();
            connection.Open();
            using var transaction = connection.BeginTransaction();

            try
            {
                // Create Order
                _logger.LogDebug("[{Timestamp}] Creating order record for UserId: {UserId}", DateTime.UtcNow, userId);
                var orderSql = @"
                    INSERT INTO Orders (UserId, Total, Status, Date, PaymentMethod, ShippingName, ShippingAddress, ShippingCity, ShippingZip, ShippingPhone) 
                    VALUES (@UserId, @Total, 'Pending', GETDATE(), @PaymentMethod, @ShippingName, @ShippingAddress, @ShippingCity, @ShippingZip, @ShippingPhone);
                    SELECT CAST(SCOPE_IDENTITY() as int)";
                
                var orderId = await connection.ExecuteScalarAsync<int>(orderSql, new 
                { 
                    UserId = userId, 
                    dto.Total, 
                    dto.PaymentMethod,
                    dto.ShippingName,
                    dto.ShippingAddress,
                    dto.ShippingCity,
                    dto.ShippingZip,
                    dto.ShippingPhone
                }, transaction);

                _logger.LogDebug("[{Timestamp}] Order created with ID: {OrderId}. Inserting {ItemCount} order items", 
                    DateTime.UtcNow, orderId, dto.Items.Count);

                // Create OrderItems
                var itemSql = "INSERT INTO OrderItems (OrderId, ProductId, Quantity, Price) VALUES (@OrderId, @ProductId, @Quantity, @Price)";
                
                foreach (var item in dto.Items)
                {
                    await connection.ExecuteAsync(itemSql, new 
                    { 
                        OrderId = orderId, 
                        item.ProductId, 
                        item.Quantity, 
                        item.Price 
                    }, transaction);
                    
                    _logger.LogDebug("[{Timestamp}] Added item - OrderId: {OrderId}, ProductId: {ProductId}, Quantity: {Quantity}, Price: {Price}", 
                        DateTime.UtcNow, orderId, item.ProductId, item.Quantity, item.Price);
                }

                transaction.Commit();
                
                _logger.LogInformation("[{Timestamp}] ✅ Order created successfully - OrderId: {OrderId}, UserId: {UserId}, Total: {Total}, Items: {ItemCount}", 
                    DateTime.UtcNow, orderId, userId, dto.Total, dto.Items.Count);

                return Ok(new { OrderId = orderId, Message = "Order placed successfully" });
            }
            catch (SqlException ex)
            {
                transaction.Rollback();
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error during order creation - UserId: {UserId}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, userId, ex.Message);
                return StatusCode(500, "An error occurred while creating the order.");
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error during order creation - UserId: {UserId}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, userId, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }

        [HttpGet("my-orders")]
        public async Task<IActionResult> GetMyOrders()
        {
            var timestamp = DateTime.UtcNow;
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            
            _logger.LogInformation("[{Timestamp}] Fetching orders for UserId: {UserId}", timestamp, userId);

            try
            {
                using var connection = CreateConnection();
                
                // Get Orders
                _logger.LogDebug("[{Timestamp}] Querying orders for UserId: {UserId}", DateTime.UtcNow, userId);
                var orders = await connection.QueryAsync<Order>("SELECT * FROM Orders WHERE UserId = @UserId ORDER BY Date DESC", new { UserId = userId });
                
                var ordersList = orders.ToList();
                _logger.LogDebug("[{Timestamp}] Found {OrderCount} orders for UserId: {UserId}", DateTime.UtcNow, ordersList.Count, userId);

                // Populate Items and Feedback
                var itemSql = @"
                    SELECT oi.*, p.Name as ProductName 
                    FROM OrderItems oi 
                    JOIN Products p ON oi.ProductId = p.Id 
                    WHERE oi.OrderId = @OrderId";

                var feedbackSql = "SELECT * FROM OrderFeedbacks WHERE OrderId = @OrderId";

                foreach (var order in ordersList)
                {
                    order.Items = (await connection.QueryAsync<OrderItem>(itemSql, new { OrderId = order.Id })).ToList();
                    order.Feedback = await connection.QueryFirstOrDefaultAsync<OrderFeedback>(feedbackSql, new { OrderId = order.Id });
                    _logger.LogDebug("[{Timestamp}] Loaded {ItemCount} items and feedback for OrderId: {OrderId}", DateTime.UtcNow, order.Items.Count, order.Id);
                }

                _logger.LogInformation("[{Timestamp}] ✅ Successfully fetched {OrderCount} orders for UserId: {UserId}", 
                    DateTime.UtcNow, ordersList.Count, userId);

                return Ok(ordersList);
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error while fetching orders - UserId: {UserId}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, userId, ex.Message);
                return StatusCode(500, "An error occurred while fetching orders.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error while fetching orders - UserId: {UserId}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, userId, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Order>> GetOrder(int id)
        {
            var timestamp = DateTime.UtcNow;
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            
            _logger.LogInformation("[{Timestamp}] Fetching order details - OrderId: {OrderId}, UserId: {UserId}", timestamp, id, userId);

            try
            {
                using var connection = CreateConnection();
                
                _logger.LogDebug("[{Timestamp}] Querying order - OrderId: {OrderId}, UserId: {UserId}", DateTime.UtcNow, id, userId);
                var order = await connection.QueryFirstOrDefaultAsync<Order>("SELECT * FROM Orders WHERE Id = @Id AND UserId = @UserId", new { Id = id, UserId = userId });

                if (order == null)
                {
                    _logger.LogWarning("[{Timestamp}] Order not found or access denied - OrderId: {OrderId}, UserId: {UserId}", 
                        DateTime.UtcNow, id, userId);
                    return NotFound();
                }

                _logger.LogDebug("[{Timestamp}] Loading order items for OrderId: {OrderId}", DateTime.UtcNow, id);
                var itemSql = @"
                    SELECT oi.*, p.Name as ProductName 
                    FROM OrderItems oi 
                    JOIN Products p ON oi.ProductId = p.Id 
                    WHERE oi.OrderId = @OrderId";
                
                order.Items = (await connection.QueryAsync<OrderItem>(itemSql, new { OrderId = id })).ToList();
                order.Feedback = await connection.QueryFirstOrDefaultAsync<OrderFeedback>("SELECT * FROM OrderFeedbacks WHERE OrderId = @OrderId", new { OrderId = id });

                _logger.LogInformation("[{Timestamp}] ✅ Successfully fetched order with feedback - OrderId: {OrderId}, UserId: {UserId}, Items: {ItemCount}, Total: {Total}", 
                    DateTime.UtcNow, id, userId, order.Items.Count, order.Total);

                return order;
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error while fetching order - OrderId: {OrderId}, UserId: {UserId}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, id, userId, ex.Message);
                return StatusCode(500, "An error occurred while fetching the order.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error while fetching order - OrderId: {OrderId}, UserId: {UserId}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, id, userId, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }
    }
}
