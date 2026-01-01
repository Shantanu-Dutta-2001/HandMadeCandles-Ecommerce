using CandleApi.Models;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CandleApi.Controllers.Admin
{
    [Route("api/admin/products")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminProductsController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<AdminProductsController> _logger;

        public AdminProductsController(IConfiguration configuration, ILogger<AdminProductsController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        [HttpPost]
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
        public async Task<IActionResult> DeleteProduct(int id)
        {
            using var connection = CreateConnection();
            var affected = await connection.ExecuteAsync("DELETE FROM Products WHERE Id = @Id", new { Id = id });
            if (affected == 0) return NotFound();
            
            return Ok();
        }
    }
}
