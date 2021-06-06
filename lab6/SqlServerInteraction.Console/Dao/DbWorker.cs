using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using StackExchange.Redis;


namespace SqlServerInteraction.Console.Dao
{
    class DbWorker
    {
        private SqlConnection connection;

        public DbWorker(string connectionString)
        {
            this.connection = new SqlConnection(connectionString);
        }

        public SqlConnection Connect()
        {
            if (this.connection.State != System.Data.ConnectionState.Open)
            {
                connection.Open();
            }

            return this.connection;
        }

        /// <summary>
        /// Выбирает CustomerID, CompanyName, City
        /// из таблицы Customers, которые соответсвуют
        /// заказам из города входного параметра ShipCity таблицы Orders
        /// </summary>
        public IEnumerable<Customer> SelectCustomers(string ShipCity)
        {
            var command = this.Connect().CreateCommand();

            command.CommandText = @"
                select c.CustomerID, c.CompanyName, c.City
                  from Customers c
                  join Orders o on o.CustomerID = c.CustomerID
                 where ShipCity = @ShipCity";

            command.Parameters.AddWithValue("ShipCity", ShipCity);


            string redisKey = command.CommandText.Replace("@ShipCity","'"+ShipCity+ "'");
            System.Console.WriteLine(redisKey);
            string redisValue;

            using (ConnectionMultiplexer redis = ConnectionMultiplexer.Connect("localhost"))
            {
                IDatabase db = redis.GetDatabase();
                redisValue = db.StringGet(redisKey);


                if (string.IsNullOrEmpty(redisValue))
                {
                    var reader = command.ExecuteReader();
                    var customers = new List<Customer>();

                    while (reader.Read())
                    {
                        var customer = new Customer();

                        customer.CustomerID = (string)reader["CustomerID"];
                        customer.CompanyName = ReadNullable<string>(reader, "CompanyName");
                        customer.City = ReadNullable<string>(reader, "City");

                        customers.Add(customer);
                    }
                    reader.Close();

                    string json = JsonConvert.SerializeObject(customers);
                    db.StringSet(redisKey, json, TimeSpan.FromSeconds(60));

                    return customers;
                }
                else
                {
                    var customers = new List<Customer>();
                    customers = JsonConvert.DeserializeObject<List<Customer>>(redisValue);
                    return customers;
                }
            }

        }

        /// <summary>
        /// Вставляет новую запись в таблицу Categories
        /// и возвращает id вставленно записи
        /// </summary>
        public int InsertCategories()
        {
            using (ConnectionMultiplexer redis = ConnectionMultiplexer.Connect("localhost"))
            {
                IDatabase db = redis.GetDatabase();

                var endpoints = redis.GetEndPoints();
                var server = redis.GetServer(endpoints.First());

                var keys = server.Keys();
                foreach (var key in keys)
                {
                    System.Console.WriteLine("Removing Key {0} from cache", key.ToString());
                    db.KeyDelete(key);
                }
            }

            var command = this.Connect().CreateCommand();

            command.CommandText = @"
                insert Categories output INSERTED.CategoryID
                values ('CategoryMy','lala',null)";

            return (int)command.ExecuteScalar(); ;
        }

        /// <summary>
        /// Апдейтит ранее вставленные записи
        /// </summary>
        public void UpdateCategories()
        {
            using (ConnectionMultiplexer redis = ConnectionMultiplexer.Connect("localhost"))
            {
                IDatabase db = redis.GetDatabase();

                var endpoints = redis.GetEndPoints();
                var server = redis.GetServer(endpoints.First());

                var keys = server.Keys();
                foreach (var key in keys)
                {
                    System.Console.WriteLine("Removing Key {0} from cache", key.ToString());
                    db.KeyDelete(key);
                }
            }

            var command = this.Connect().CreateCommand();

            command.CommandText = @"
                update Categories 
                   set CategoryName = 'CategoryMy2'
                 where CategoryName = 'CategoryMy'";

            command.ExecuteScalar(); ;
        }

        /// <summary>
        /// Удаляет ранее вставленные записи
        /// </summary>
        public void DeleteCategories()
        {
            using (ConnectionMultiplexer redis = ConnectionMultiplexer.Connect("localhost"))
            {
                IDatabase db = redis.GetDatabase();

                var endpoints = redis.GetEndPoints();
                var server = redis.GetServer(endpoints.First());

                var keys = server.Keys();
                foreach (var key in keys)
                {
                    System.Console.WriteLine("Removing Key {0} from cache", key.ToString());
                    db.KeyDelete(key);
                }
            }

            var command = this.Connect().CreateCommand();

            command.CommandText = @"
                delete Categories
                 where CategoryName = 'CategoryMy2'";

            command.ExecuteScalar(); ;
        }

        /// <summary>
        /// Вставляет новые записи в таблицу Categories
        /// двойной командой
        /// </summary>
        public void InsertCategoriesBeginTransaction()
        {
            using (ConnectionMultiplexer redis = ConnectionMultiplexer.Connect("localhost"))
            {
                IDatabase db = redis.GetDatabase();

                var endpoints = redis.GetEndPoints();
                var server = redis.GetServer(endpoints.First());

                var keys = server.Keys();
                foreach (var key in keys)
                {
                    System.Console.WriteLine("Removing Key {0} from cache", key.ToString());
                    db.KeyDelete(key);
                }
            }

            SqlTransaction transaction = connection.BeginTransaction();

            var command = this.Connect().CreateCommand();

            command.Transaction = transaction;
            try
            {           
                command.CommandText = @"
                    insert Categories output INSERTED.CategoryID
                    values ('CategoryMy','lala',null)";
                command.ExecuteNonQuery();
                command.CommandText = @"
                    insert Categories output INSERTED.CategoryID
                    values ('CategoryMy','lala',null)";
                command.ExecuteNonQuery();
                transaction.Commit();
            }

            catch (Exception ex)
            {
                transaction.Rollback();
                System.Console.WriteLine(ex.Message);
            }
        }


        private T ReadNullable<T>(SqlDataReader reader, string columnName)
            where T: class
        {
            object value = reader[columnName];

            return value == DBNull.Value ? null : (T)value;
        }
    }
}
