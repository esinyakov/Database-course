using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks; 

namespace SqlServerInteraction.Console.Dao
{
    class DbWorkerFactory
    {
        public DbWorker Create()
        {
            string key = "Northwind";
            var connectionStringSettings = ConfigurationManager.ConnectionStrings[key];
            
            if (connectionStringSettings == null)
            {
                throw new Exception($"Connection string settings with key \"{connectionStringSettings.ConnectionString}\" not found in application configuration.");
            }
            
            return new DbWorker(connectionStringSettings.ConnectionString);
        }
    }
}
