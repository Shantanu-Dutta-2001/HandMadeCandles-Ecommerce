using CandleApi.Models;
using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Security.Claims;

namespace CandleApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class AddressController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<AddressController> _logger;

        public AddressController(IConfiguration configuration, ILogger<AddressController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection CreateConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        [HttpGet]
        public async Task<IActionResult> GetAddresses()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");

            using var connection = CreateConnection();
            var addresses = await connection.QueryAsync<Address>("SELECT * FROM Addresses WHERE UserId = @UserId", new { UserId = userId });
            
            return Ok(addresses);
        }

        [HttpPost]
        public async Task<IActionResult> AddAddress(Address address)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            address.UserId = userId;

            using var connection = CreateConnection();
            
            // If this is the first address, make it default
            var count = await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM Addresses WHERE UserId = @UserId", new { UserId = userId });
            if (count == 0)
            {
                address.IsDefault = true;
            }

            // If new address is default, unset others
            if (address.IsDefault)
            {
                await connection.ExecuteAsync("UPDATE Addresses SET IsDefault = 0 WHERE UserId = @UserId", new { UserId = userId });
            }

            var sql = @"
                INSERT INTO Addresses (UserId, Name, AddressLine, City, Zip, Phone, IsDefault) 
                VALUES (@UserId, @Name, @AddressLine, @City, @Zip, @Phone, @IsDefault);
                SELECT CAST(SCOPE_IDENTITY() as int)";

            var id = await connection.ExecuteScalarAsync<int>(sql, address);
            address.Id = id;

            return Ok(address);
        }
    }
}
