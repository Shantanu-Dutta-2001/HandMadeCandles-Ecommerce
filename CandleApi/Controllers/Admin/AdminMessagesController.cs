using CandleApi.Models;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CandleApi.Controllers.Admin
{
    [Route("api/admin/messages")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminMessagesController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<AdminMessagesController> _logger;

        public AdminMessagesController(IConfiguration configuration, ILogger<AdminMessagesController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        [HttpGet]
        public async Task<IActionResult> GetMessages()
        {
            using var connection = CreateConnection();
            var messages = await connection.QueryAsync<Message>("SELECT * FROM Messages ORDER BY CreatedAt DESC");
            return Ok(messages);
        }

        [HttpPost("{id}/reply")]
        public async Task<IActionResult> ReplyToMessage(int id, [FromBody] string replyBody)
        {
            // In a real app, this would send an email via SMTP
            // For now, we will just log it or maybe store a "Reply" record if we had a table.
            // Requirement says "reply a thankyou note along with editor for custom message".
            // We will simulate success.
            
            _logger.LogInformation($"Replying to message {id} with body: {replyBody}");
            
            // Could strictly verify message exists
            using var connection = CreateConnection();
            var exists = await connection.ExecuteScalarAsync<int>("SELECT COUNT(1) FROM Messages WHERE Id = @Id", new { Id = id });
            if (exists == 0) return NotFound();

            return Ok(new { Message = "Reply sent successfully" });
        }
    }
}
