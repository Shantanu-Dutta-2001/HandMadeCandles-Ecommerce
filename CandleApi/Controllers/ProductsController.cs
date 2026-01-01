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
    public class ProductsController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(IConfiguration configuration, ILogger<ProductsController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetProducts()
        {
            var timestamp = DateTime.UtcNow;
            _logger.LogInformation("[{Timestamp}] Fetching all products", timestamp);

            try
            {
                using var connection = CreateConnection();
                var products = await connection.QueryAsync<Product>("SELECT * FROM Products");
                var productsList = products.ToList();

                _logger.LogInformation("[{Timestamp}] ✅ Successfully fetched {ProductCount} products", 
                    DateTime.UtcNow, productsList.Count);

                return Ok(productsList);
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error while fetching products. Error: {ErrorMessage}", 
                    DateTime.UtcNow, ex.Message);
                return StatusCode(500, "An error occurred while fetching products.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error while fetching products. Error: {ErrorMessage}", 
                    DateTime.UtcNow, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<ActionResult<Product>> GetProduct(int id)
        {
            var timestamp = DateTime.UtcNow;
            _logger.LogInformation("[{Timestamp}] Fetching product - ProductId: {ProductId}", timestamp, id);

            try
            {
                using var connection = CreateConnection();
                var product = await connection.QueryFirstOrDefaultAsync<Product>("SELECT * FROM Products WHERE Id = @Id", new { Id = id });

                if (product == null)
                {
                    _logger.LogWarning("[{Timestamp}] Product not found - ProductId: {ProductId}", DateTime.UtcNow, id);
                    return NotFound();
                }

                _logger.LogInformation("[{Timestamp}] ✅ Successfully fetched product - ProductId: {ProductId}, Name: {ProductName}, Price: {Price}", 
                    DateTime.UtcNow, id, product.Name, product.Price);

                return product;
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Database error while fetching product - ProductId: {ProductId}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, id, ex.Message);
                return StatusCode(500, "An error occurred while fetching the product.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[{Timestamp}] ❌ Unexpected error while fetching product - ProductId: {ProductId}, Error: {ErrorMessage}", 
                    DateTime.UtcNow, id, ex.Message);
                return StatusCode(500, "An unexpected error occurred.");
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CreateProduct(Product product)
        {
            using var connection = CreateConnection();
            var sql = @"
                INSERT INTO Products (Name, Description, Price, Image, Category, Rating) 
                VALUES (@Name, @Description, @Price, @Image, @Category, @Rating);
                SELECT CAST(SCOPE_IDENTITY() as int)";
            
            var id = await connection.ExecuteScalarAsync<int>(sql, product);
            product.Id = id;
            return Ok(product);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateProduct(int id, Product product)
        {
            using var connection = CreateConnection();
            var sql = @"
                UPDATE Products 
                SET Name = @Name, Description = @Description, Price = @Price, 
                    Image = @Image, Category = @Category, Rating = @Rating
                WHERE Id = @Id";
            
            product.Id = id;
            var affected = await connection.ExecuteAsync(sql, product);
            if (affected == 0) return NotFound();
            
            return Ok(product);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            using var connection = CreateConnection();
            var affected = await connection.ExecuteAsync("DELETE FROM Products WHERE Id = @Id", new { Id = id });
            if (affected == 0) return NotFound();
            
            return Ok();
        }
    }
}
