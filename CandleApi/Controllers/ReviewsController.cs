using Microsoft.AspNetCore.Mvc;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Data.SqlClient;
using CandleApi.Models;

namespace CandleApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewsController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ReviewsController> _logger;

        public ReviewsController(IConfiguration configuration, ILogger<ReviewsController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<Review>>> GetReviews()
        {
            var timestamp = DateTime.UtcNow;
            _logger.LogInformation("[{Timestamp}] Fetching latest reviews", timestamp);

            try
            {
                using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
                var reviews = await connection.QueryAsync<Review>("SELECT TOP 3 * FROM Reviews ORDER BY Date DESC");
                var reviewsList = reviews.ToList();

                _logger.LogInformation("[{Timestamp}] ✅ Successfully fetched {ReviewCount} reviews", 
                    DateTime.UtcNow, reviewsList.Count);

                return Ok(reviewsList);
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error while fetching reviews. Error: {ErrorMessage}", 
                    DateTime.UtcNow, ex.Message);
                return StatusCode(500, "An error occurred while fetching reviews.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error while fetching reviews. Error: {ErrorMessage}", 
                    DateTime.UtcNow, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }
    }
}
