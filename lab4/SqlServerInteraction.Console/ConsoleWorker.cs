using SqlServerInteraction.Console.Dao;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SqlServerInteraction.Console
{
    class ConsoleWorker
    {
        public void WriteCustomers(IEnumerable<Customer> customers)
        {
            System.Console.WriteLine("Customers:");
            foreach (var customer in customers)
            {
                System.Console.Write("  - ");
                WriteCustomer(customer);
            }
        }

        public void WriteCustomer(Customer customer)
        {
            System.Console.WriteLine("CustomerID: #{0} CompanyName: {1} City: {2}",
                customer.CustomerID,
                customer.CompanyName,
                customer.City);
        }

        public void WriteCategoryID(int id)
        {
            System.Console.WriteLine("Inserted CategoryID: {0}", id);
        }
    }
}
