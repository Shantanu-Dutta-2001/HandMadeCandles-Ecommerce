using Microsoft.AspNetCore.Mvc;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Data.SqlClient;
using CandleApi.Models;

namespace CandleApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessagesController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<MessagesController> _logger;

        public MessagesController(IConfiguration configuration, ILogger<MessagesController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        [HttpPost]
        [AllowAnonymous]
        public async Task<IActionResult> SendMessage(Message message)
        {
            var timestamp = DateTime.UtcNow;
            _logger.LogInformation("[{Timestamp}] Message submission started - From: {Name}, Email: {Email}, Subject: {Subject}", 
                timestamp, message.Name, message.Email, message.Subject);

            try
            {
                using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
                
                var sql = @"INSERT INTO Messages (Name, Email, Subject, Body, CreatedAt) 
                            VALUES (@Name, @Email, @Subject, @Body, GETDATE())";
                
                await connection.ExecuteAsync(sql, message);

                _logger.LogInformation("[{Timestamp}] ✅ Message received successfully - From: {Name}, Email: {Email}, Subject: {Subject}", 
                    DateTime.UtcNow, message.Name, message.Email, message.Subject);

                return Ok(new { message = "Message received successfully" });
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error while saving message - From: {Name}, Email: {Email}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, message.Name, message.Email, ex.Message);
                return StatusCode(500, "An error occurred while saving the message.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error while saving message - From: {Name}, Email: {Email}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, message.Name, message.Email, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }
    }
}
